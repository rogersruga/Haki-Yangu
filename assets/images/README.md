# App Icon Generation for Haki Yangu

## Quick Setup Instructions

### Option 1: Use the HTML Generator (Recommended)
1. Open `create_simple_icon.html` in any web browser
2. Click "Generate Icon" to create the icon
3. Click "Download PNG" to save as `app_icon.png`
4. Move the downloaded file to `assets/images/app_icon.png`

### Option 2: Create Manually
Create a 1024x1024 PNG image with:
- Green circular background (#1B5E20)
- White inner circle (80% of the size)
- Balance/scales of justice icon in the center (green #1B5E20)
- Optional: "HAKI YANGU" text at the bottom

### Option 3: Use Online Icon Generator
1. Go to any online icon generator (like Canva, GIMP, or Photoshop)
2. Create a 1024x1024 image
3. Use the design specifications above
4. Save as `app_icon.png`

## After Creating the Icon

1. Place the icon file at: `assets/images/app_icon.png`
2. Run: `flutter pub get`
3. Run: `flutter pub run flutter_launcher_icons`
4. Rebuild your app

## Icon Design Specifications

- **Size**: 1024x1024 pixels
- **Background**: Circular, green (#1B5E20)
- **Inner Circle**: White, 80% of background size
- **Main Icon**: Balance/scales of justice
- **Color**: Green (#1B5E20) for the scales
- **Text**: "HAKI YANGU" (optional)
- **Style**: Clean, professional, civic/legal theme

## Current Status

The flutter_launcher_icons package is configured in pubspec.yaml and ready to generate icons for:
- Android
- iOS  
- Web
- Windows
- macOS

Just add the `app_icon.png` file and run the generation command!
