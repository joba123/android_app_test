package com.example.androidapptest.ads

import android.app.Activity
import android.content.Context
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class AdMobManager(private val context: Context) {
    private var interstitialAd: InterstitialAd? = null
    private var rewardedAd: RewardedAd? = null
    private var interstitialLoading = false
    private var rewardedLoading = false

    private val _isRewardedAdReady = MutableStateFlow(false)
    val isRewardedAdReady: StateFlow<Boolean> = _isRewardedAdReady.asStateFlow()

    fun initialize() {
        MobileAds.initialize(context) {
            loadInterstitialAd()
            loadRewardedAd()
        }
    }

    fun showInterstitialAfterGameOver(activity: Activity, onFinished: () -> Unit) {
        val ad = interstitialAd ?: run {
            loadInterstitialAd()
            onFinished()
            return
        }
        interstitialAd = null
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                loadInterstitialAd()
                onFinished()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                loadInterstitialAd()
                onFinished()
            }
        }
        ad.show(activity)
    }

    fun showRewardedAd(activity: Activity, onRewardEarned: () -> Unit, onAdUnavailable: () -> Unit) {
        val ad = rewardedAd ?: run {
            onAdUnavailable()
            loadRewardedAd()
            return
        }
        rewardedAd = null
        _isRewardedAdReady.value = false
        var rewardEarned = false
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                loadRewardedAd()
                if (!rewardEarned) onAdUnavailable()
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                loadRewardedAd()
                onAdUnavailable()
            }
        }
        ad.show(activity) {
            rewardEarned = true
            onRewardEarned()
        }
    }

    fun loadInterstitialAd() {
        if (interstitialLoading || interstitialAd != null) return
        interstitialLoading = true
        InterstitialAd.load(
            context,
            AdMobConfig.INTERSTITIAL_AD_UNIT_ID,
            AdRequest.Builder().build(),
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    interstitialLoading = false
                    interstitialAd = ad
                }

                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                    interstitialLoading = false
                    interstitialAd = null
                }
            }
        )
    }

    fun loadRewardedAd() {
        if (rewardedLoading || rewardedAd != null) return
        rewardedLoading = true
        RewardedAd.load(
            context,
            AdMobConfig.REWARDED_AD_UNIT_ID,
            AdRequest.Builder().build(),
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedLoading = false
                    rewardedAd = ad
                    _isRewardedAdReady.value = true
                }

                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                    rewardedLoading = false
                    rewardedAd = null
                    _isRewardedAdReady.value = false
                }
            }
        )
    }
}

object AdMobConfig {
    private const val USE_TEST_ADS = true
    private const val TEST_INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"
    private const val TEST_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"
    private const val PLACEHOLDER_INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx"
    private const val PLACEHOLDER_REWARDED_AD_UNIT_ID = "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx"

    val INTERSTITIAL_AD_UNIT_ID: String =
        if (USE_TEST_ADS) TEST_INTERSTITIAL_AD_UNIT_ID else PLACEHOLDER_INTERSTITIAL_AD_UNIT_ID
    val REWARDED_AD_UNIT_ID: String =
        if (USE_TEST_ADS) TEST_REWARDED_AD_UNIT_ID else PLACEHOLDER_REWARDED_AD_UNIT_ID
}
