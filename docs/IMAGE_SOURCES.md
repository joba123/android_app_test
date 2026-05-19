# Image sources

Card background images are stored as metadata on `ComparisonItem` in `ComparisonCatalog.kt`.

Each item can define:

- `imageUrl`
- `imageSource`
- `imageAuthor`
- `imageAttributionText`
- `imageLicenseUrl`
- `imageSearchQuery`
- `imageVerified`

The catalog uses two layers:

- item-specific images in `imagesByTitle`, for example concrete car and city photos
- fallback images in `fallbackImagesBySubCategory`, so every category still works if an item has no dedicated image

This avoids automatic use of club logos, film posters, celebrity portraits, or other rights-sensitive imagery. Brand-specific car photos should only be added from a page with a clear license and stored with source, author, license URL, and search query.

## Adding Images

1. Use sources with clear licensing, preferably Pexels or Pixabay.
2. Do not use Google Images as a source.
3. Prefer neutral photos when the item is a brand, club, celebrity, or protected property.
4. Store the photo source, author, license URL, and original search query.
5. Set `imageVerified = true` only after checking that the direct image URL loads and the source page marks the image as free to use.
6. Leave image fields empty if no safe image is available; the card automatically falls back to its gradient background.

Pexels license page: https://www.pexels.com/license/
Pixabay license summary: https://pixabay.com/service/license-summary/

Example direct image URL format:

```text
https://images.pexels.com/photos/<photo-id>/pexels-photo-<photo-id>.jpeg?auto=compress&cs=tinysrgb&w=1200
```

If a future import script uses the Pexels or Pixabay API, keep API keys out of source control. Load them from `local.properties`, `gradle.properties`, or environment variables.
