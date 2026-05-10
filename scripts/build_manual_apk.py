#!/usr/bin/env python3
"""Build the Sternenlabyrinth APK without requiring the Android SDK.

It emits a valid APK with a binary AndroidManifest.xml, the WebView Activity
DEX, and the HTML/CSS/JavaScript game asset used by the Gradle project.
"""
from __future__ import annotations

import hashlib
import os
import struct
import subprocess
import tempfile
import zlib
import zipfile
from pathlib import Path

PACKAGE = "com.example.androidapptest"
APK_UNSIGNED = Path("build/outputs/apk/debug/app-debug-unsigned.apk")
APK_SIGNED = Path("build/outputs/apk/debug/app-debug.apk")


def uleb128(value: int) -> bytes:
    out = bytearray()
    while True:
        b = value & 0x7F
        value >>= 7
        if value:
            out.append(b | 0x80)
        else:
            out.append(b)
            return bytes(out)


def align4(b: bytearray) -> None:
    while len(b) % 4:
        b.append(0)


def mutf8(s: str) -> bytes:
    return s.encode("utf-8") + b"\x00"


def type_desc(name: str) -> str:
    if len(name) == 1 and name in "VZBSCIJFD":
        return name
    if name.startswith("[") or (name.startswith("L") and name.endswith(";")):
        return name
    return "L" + name.replace(".", "/") + ";"


class DexBuilder:
    def __init__(self) -> None:
        self.strings: list[str] = []
        self.types: list[str] = []
        self.protos: list[tuple[str, tuple[str, ...]]] = []
        self.methods: list[tuple[str, str, tuple[str, tuple[str, ...]]]] = []
        self.code_items: list[tuple[int, bytes]] = []

    def s(self, value: str) -> int:
        if value not in self.strings:
            self.strings.append(value)
        return self.strings.index(value)

    def t(self, desc: str) -> int:
        self.s(desc)
        if desc not in self.types:
            self.types.append(desc)
        return self.types.index(desc)

    @staticmethod
    def shorty(desc: str) -> str:
        return desc[0] if desc[0] in "VZBSCIJFD" else "L"

    def proto(self, ret: str, params: tuple[str, ...]) -> int:
        self.t(ret)
        for p in params:
            self.t(p)
        item = (ret, params)
        if item not in self.protos:
            self.protos.append(item)
        return self.protos.index(item)

    def method(self, cls: str, name: str, ret: str, params: tuple[str, ...]) -> int:
        self.t(cls)
        self.s(name)
        proto = (ret, params)
        self.proto(ret, params)
        item = (cls, name, proto)
        if item not in self.methods:
            self.methods.append(item)
        return self.methods.index(item)

    @staticmethod
    def ins_10x(op: int) -> bytes:
        return struct.pack("<H", op)

    @staticmethod
    def ins_11n(op: int, a: int, lit4: int) -> bytes:
        return struct.pack("<H", op | (a << 8) | ((lit4 & 0xF) << 12))

    @staticmethod
    def ins_21s(op: int, a: int, lit: int) -> bytes:
        return struct.pack("<HH", op | (a << 8), lit & 0xFFFF)

    @staticmethod
    def ins_21c(op: int, a: int, idx: int) -> bytes:
        return struct.pack("<HH", op | (a << 8), idx)

    @staticmethod
    def ins_35c(op: int, regs: list[int], idx: int) -> bytes:
        count = len(regs)
        padded = regs + [0] * (5 - count)
        c, d, e, f, g = padded[:5]
        first = op | (count << 12) | (g << 8)
        third = c | (d << 4) | (e << 8) | (f << 12)
        return struct.pack("<HHH", first, idx, third)

    def build_code(self, registers: int, ins: int, outs: int, bytecode: bytes) -> bytes:
        insns_size = len(bytecode) // 2
        item = bytearray(struct.pack("<HHHHII", registers, ins, outs, 0, 0, insns_size))
        item += bytecode
        if insns_size % 2:
            item += b"\x00\x00"
        return bytes(item)

    def build(self) -> bytes:
        main = type_desc(PACKAGE + ".MainActivity")
        activity = "Landroid/app/Activity;"
        bundle = "Landroid/os/Bundle;"
        context = "Landroid/content/Context;"
        view = "Landroid/view/View;"
        webview = "Landroid/webkit/WebView;"
        websettings = "Landroid/webkit/WebSettings;"
        string = "Ljava/lang/String;"
        void = "V"
        boolean = "Z"
        int_t = "I"

        for t in [main, activity, bundle, context, view, webview, websettings, string, void, boolean, int_t]:
            self.t(t)

        self.method(activity, "<init>", void, ())
        self.method(main, "<init>", void, ())
        self.method(activity, "onCreate", void, (bundle,))
        self.method(main, "onCreate", void, (bundle,))
        self.method(webview, "<init>", void, (context,))
        self.method(webview, "getSettings", websettings, ())
        self.method(websettings, "setJavaScriptEnabled", void, (boolean,))
        self.method(websettings, "setDomStorageEnabled", void, (boolean,))
        self.method(view, "setBackgroundColor", void, (int_t,))
        self.method(webview, "loadUrl", void, (string,))
        self.method(activity, "setContentView", void, (view,))
        self.s("file:///android_asset/index.html")
        self.s("MainActivity.java")

        for ret, params_tuple in list(self.protos):
            self.s(self.shorty(ret) + "".join(self.shorty(p) for p in params_tuple))

        # Stable sorting required by the DEX format.
        self.strings.sort()
        self.types.sort(key=lambda d: self.s(d))
        self.protos.sort(key=lambda p: (self.t(p[0]), tuple(self.t(x) for x in p[1])))
        self.methods.sort(key=lambda m: (self.t(m[0]), self.proto(*m[2]), self.s(m[1])))

        m_main_init = self.methods.index((main, "<init>", (void, ())))
        m_main_oncreate = self.methods.index((main, "onCreate", (void, (bundle,))))
        m_activity_init = self.methods.index((activity, "<init>", (void, ())))
        m_activity_oncreate = self.methods.index((activity, "onCreate", (void, (bundle,))))
        m_webview_init = self.methods.index((webview, "<init>", (void, (context,))))
        m_get_settings = self.methods.index((webview, "getSettings", (websettings, ())))
        m_js = self.methods.index((websettings, "setJavaScriptEnabled", (void, (boolean,))))
        m_dom = self.methods.index((websettings, "setDomStorageEnabled", (void, (boolean,))))
        m_bg = self.methods.index((view, "setBackgroundColor", (void, (int_t,))))
        m_load = self.methods.index((webview, "loadUrl", (void, (string,))))
        m_set_content = self.methods.index((activity, "setContentView", (void, (view,))))
        s_url = self.s("file:///android_asset/index.html")

        init_bc = b"".join([
            self.ins_35c(0x70, [0], m_activity_init),
            self.ins_10x(0x0e),
        ])
        init_code = self.build_code(1, 1, 1, init_bc)

        oncreate_bc = b"".join([
            self.ins_35c(0x6f, [3, 4], m_activity_oncreate),      # super.onCreate(bundle)
            self.ins_21c(0x22, 0, self.t(webview)),               # new-instance v0, WebView
            self.ins_35c(0x70, [0, 3], m_webview_init),           # WebView(this)
            self.ins_35c(0x6e, [0], m_get_settings),              # getSettings()
            self.ins_11n(0x0c, 1, 0),                             # move-result-object v1
            self.ins_11n(0x12, 2, 1),                             # const/4 v2, #1
            self.ins_35c(0x6e, [1, 2], m_js),                     # setJavaScriptEnabled(true)
            self.ins_35c(0x6e, [1, 2], m_dom),                    # setDomStorageEnabled(true)
            self.ins_21s(0x13, 2, 0xFF08),                        # const/16 v2, -0x6fe2 (0xFFFF901e low part)
            self.ins_35c(0x6e, [0, 2], m_bg),                     # setBackgroundColor(fallback dark)
            self.ins_21c(0x1a, 1, s_url),                         # const-string v1, url
            self.ins_35c(0x6e, [0, 1], m_load),                   # loadUrl(url)
            self.ins_35c(0x6e, [3, 0], m_set_content),            # setContentView(webView)
            self.ins_10x(0x0e),
        ])
        oncreate_code = self.build_code(5, 2, 2, oncreate_bc)

        data = bytearray()
        string_offsets = []
        for s in self.strings:
            string_offsets.append(len(data))
            data += uleb128(len(s)) + mutf8(s)
        align4(data)

        type_list_offsets = {}
        for _ret, params_tuple in self.protos:
            if params_tuple and params_tuple not in type_list_offsets:
                align4(data)
                type_list_offsets[params_tuple] = len(data)
                data += struct.pack("<I", len(params_tuple))
                for p in params_tuple:
                    data += struct.pack("<H", self.t(p))
                align4(data)

        code_init_off = len(data)
        data += init_code
        align4(data)
        code_oncreate_off = len(data)
        data += oncreate_code
        align4(data)

        class_data_off = len(data)
        class_data = bytearray()
        class_data += uleb128(1) + uleb128(0) + uleb128(1) + uleb128(0)
        class_data += uleb128(m_main_init) + uleb128(0x10001) + uleb128(code_init_off)
        class_data += uleb128(m_main_oncreate) + uleb128(0x0004) + uleb128(code_oncreate_off)
        data += class_data
        align4(data)

        data_off = 112
        map_off_in_data = len(data)
        first_type_list_off = min(type_list_offsets.values()) if type_list_offsets else 0
        map_items = [
            (0x0000, 1, 0),
            (0x0001, len(self.strings), 0),
            (0x0002, len(self.types), 0),
            (0x0003, len(self.protos), 0),
            (0x0005, len(self.methods), 0),
            (0x0006, 1, 0),
            (0x1000, 1, data_off + map_off_in_data),
        ]
        if type_list_offsets:
            map_items.append((0x1001, len(type_list_offsets), data_off + first_type_list_off))
        map_items += [
            (0x2001, 2, data_off + code_init_off),
            (0x2002, len(self.strings), data_off + string_offsets[0]),
            (0x2000, 1, data_off + class_data_off),
        ]
        map_items.sort(key=lambda x: x[0])
        data += struct.pack("<I", len(map_items))
        for typ, size, off in map_items:
            data += struct.pack("<HHII", typ, 0, size, off)
        align4(data)

        data_off = 112
        string_ids_off = data_off + len(data)
        string_ids = b"".join(struct.pack("<I", data_off + o) for o in string_offsets)
        type_ids_off = string_ids_off + len(string_ids)
        type_ids = b"".join(struct.pack("<I", self.s(t)) for t in self.types)
        proto_ids_off = type_ids_off + len(type_ids)
        proto_ids = b"".join(
            struct.pack("<III", self.s(self.shorty(ret) + "".join(self.shorty(p) for p in params)), self.t(ret), data_off + type_list_offsets[params] if params else 0)
            for ret, params in self.protos
        )
        field_ids_off = proto_ids_off + len(proto_ids)
        method_ids_off = field_ids_off
        method_ids = b"".join(
            struct.pack("<HHI", self.t(cls), self.proto(*proto), self.s(name))
            for cls, name, proto in self.methods
        )
        class_defs_off = method_ids_off + len(method_ids)
        map_cursor = map_off_in_data + 4
        patch_offsets = {0x0001: string_ids_off, 0x0002: type_ids_off, 0x0003: proto_ids_off, 0x0005: method_ids_off, 0x0006: class_defs_off}
        for _ in range(struct.unpack_from("<I", data, map_off_in_data)[0]):
            typ = struct.unpack_from("<H", data, map_cursor)[0]
            if typ in patch_offsets:
                struct.pack_into("<I", data, map_cursor + 8, patch_offsets[typ])
            map_cursor += 12
        class_defs = struct.pack(
            "<IIIIIIII",
            self.t(main),
            0x0001 | 0x0020,
            self.t(activity),
            0,
            self.s("MainActivity.java"),
            0,
            data_off + class_data_off,
            0,
        )

        file_size = class_defs_off + len(class_defs)
        header = bytearray(112)
        header[0:8] = b"dex\n035\x00"
        struct.pack_into(
            "<20I",
            header,
            32,
            file_size,
            112,
            0x12345678,
            0,
            0,
            data_off + map_off_in_data,
            len(self.strings),
            string_ids_off,
            len(self.types),
            type_ids_off,
            len(self.protos),
            proto_ids_off,
            0,
            0,
            len(self.methods),
            method_ids_off,
            1,
            class_defs_off,
            len(data),
            data_off,
        )
        dex = header + data + string_ids + type_ids + proto_ids + method_ids + class_defs
        signature = hashlib.sha1(dex[32:]).digest()
        dex[12:32] = signature
        checksum = zlib.adler32(dex[12:]) & 0xFFFFFFFF
        struct.pack_into("<I", dex, 8, checksum)
        return bytes(dex)


def axml_string_pool(strings: list[str]) -> bytes:
    offsets = []
    body = bytearray()
    for s in strings:
        offsets.append(len(body))
        raw = s.encode("utf-8")
        body += bytes([len(s), len(raw)]) + raw + b"\x00"
    while len(body) % 4:
        body.append(0)
    header_size = 28
    strings_start = header_size + 4 * len(strings)
    size = strings_start + len(body)
    return struct.pack("<HHIIIIII", 0x0001, header_size, size, len(strings), 0, 0x100, strings_start, 0) + b"".join(struct.pack("<I", o) for o in offsets) + body


def build_manifest() -> bytes:
    strings = [
        "manifest", "package", "uses-sdk", "android", "http://schemas.android.com/apk/res/android",
        "minSdkVersion", "targetSdkVersion", "application", "label", "allowBackup", "supportsRtl",
        "activity", "name", "exported", "intent-filter", "action", "category",
        PACKAGE, ".MainActivity", "Sternenlabyrinth", "true", "android.intent.action.MAIN", "android.intent.category.LAUNCHER",
    ]
    idx = {s: i for i, s in enumerate(strings)}
    android_ns = idx["http://schemas.android.com/apk/res/android"]
    no = 0xFFFFFFFF
    chunks = bytearray()
    chunks += axml_string_pool(strings)
    resids = [0] * len(strings)
    for name, resid in {
        "minSdkVersion": 0x0101020c,
        "targetSdkVersion": 0x01010270,
        "label": 0x01010001,
        "allowBackup": 0x01010280,
        "supportsRtl": 0x010103af,
        "name": 0x01010003,
        "exported": 0x01010010,
    }.items():
        resids[idx[name]] = resid
    chunks += struct.pack("<HHI", 0x0180, 8, 8 + 4 * len(resids)) + b"".join(struct.pack("<I", r) for r in resids)

    def attr(ns: int, name: str, raw: int, typ: int, data: int) -> bytes:
        return struct.pack("<IIIHBBI", ns, idx[name], raw, 8, 0, typ, data)

    def start(name: str, attrs: list[bytes]) -> bytes:
        size = 36 + 20 * len(attrs)
        return struct.pack("<HHIIIIIHHHHHH", 0x0102, 16, size, 0, no, no, idx[name], 20, 20, len(attrs), 0, 0, 0) + b"".join(attrs)

    def end(name: str) -> bytes:
        return struct.pack("<HHIIIII", 0x0103, 16, 24, 0, no, no, idx[name])

    chunks += struct.pack("<HHIIIII", 0x0100, 16, 24, 0, no, idx["android"], android_ns)
    chunks += start("manifest", [attr(no, "package", idx[PACKAGE], 3, idx[PACKAGE])])
    chunks += start("uses-sdk", [attr(android_ns, "minSdkVersion", no, 0x10, 23), attr(android_ns, "targetSdkVersion", no, 0x10, 35)])
    chunks += end("uses-sdk")
    chunks += start("application", [
        attr(android_ns, "label", idx["Sternenlabyrinth"], 3, idx["Sternenlabyrinth"]),
        attr(android_ns, "allowBackup", idx["true"], 0x12, 0xFFFFFFFF),
        attr(android_ns, "supportsRtl", idx["true"], 0x12, 0xFFFFFFFF),
    ])
    chunks += start("activity", [attr(android_ns, "name", idx[".MainActivity"], 3, idx[".MainActivity"]), attr(android_ns, "exported", idx["true"], 0x12, 0xFFFFFFFF)])
    chunks += start("intent-filter", [])
    chunks += start("action", [attr(android_ns, "name", idx["android.intent.action.MAIN"], 3, idx["android.intent.action.MAIN"])])
    chunks += end("action")
    chunks += start("category", [attr(android_ns, "name", idx["android.intent.category.LAUNCHER"], 3, idx["android.intent.category.LAUNCHER"])])
    chunks += end("category")
    chunks += end("intent-filter")
    chunks += end("activity")
    chunks += end("application")
    chunks += end("manifest")
    chunks += struct.pack("<HHIIIII", 0x0101, 16, 24, 0, no, idx["android"], android_ns)
    return struct.pack("<HHI", 0x0003, 8, 8 + len(chunks)) + chunks


def ensure_debug_keystore(path: Path) -> None:
    if path.exists():
        return
    subprocess.run([
        "keytool", "-genkeypair", "-keystore", str(path), "-storepass", "android", "-keypass", "android",
        "-alias", "androiddebugkey", "-keyalg", "RSA", "-keysize", "2048", "-validity", "10000",
        "-dname", "CN=Android Debug,O=Android,C=US"
    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def main() -> None:
    APK_UNSIGNED.parent.mkdir(parents=True, exist_ok=True)
    manifest = build_manifest()
    dex = DexBuilder().build()
    with zipfile.ZipFile(APK_UNSIGNED, "w", compression=zipfile.ZIP_DEFLATED) as apk:
        apk.writestr("AndroidManifest.xml", manifest)
        apk.writestr("classes.dex", dex)
        apk.write("app/src/main/assets/index.html", "assets/index.html")
    key = Path("build/debug.keystore")
    ensure_debug_keystore(key)
    if APK_SIGNED.exists():
        APK_SIGNED.unlink()
    subprocess.run([
        "jarsigner", "-keystore", str(key), "-storepass", "android", "-keypass", "android",
        "-signedjar", str(APK_SIGNED), str(APK_UNSIGNED), "androiddebugkey"
    ], check=True, stdout=subprocess.DEVNULL)
    print(APK_SIGNED)


if __name__ == "__main__":
    main()
