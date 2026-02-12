# ClarityCam - City of Vaughan Geo-Stamped Camera

An iPhone camera app that captures photos with location metadata overlays for the City of Vaughan. Built with React Native + Expo so it can be developed on **Windows, Mac, or Linux**.

## Features

- **Live Camera Preview** with real-time overlay display
- **GPS Coordinates** in degrees/minutes/seconds format
- **Reverse Geocoding** — street address, city, province, postal code, country
- **Compass Heading** with cardinal direction
- **Satellite Map Thumbnail** showing current location
- **Compass Rose Widget** with live heading indicator
- **City of Vaughan Branding**
- **Auto-save** composited photos to your photo library
- **Share** stamped photos directly from the app

## Setup (Windows — Step by Step)

### 1. Install Node.js

1. Go to https://nodejs.org
2. Download the **LTS** version (the green button on the left)
3. Run the installer — click Next through everything, keep all defaults
4. When it's done, restart your computer

### 2. Download this project

1. Open **Command Prompt** (press Windows key, type `cmd`, press Enter)
2. Run these commands one at a time:
   ```
   cd %USERPROFILE%\Desktop
   git clone https://github.com/gekaizer/vaughan-claritycam.git
   cd vaughan-claritycam
   ```

### 3. Install dependencies

In the same Command Prompt window, run:
```
npm install
```
Wait for it to finish (may take a few minutes).

### 4. Install Expo Go on your iPhone

1. Open the **App Store** on your iPhone
2. Search for **"Expo Go"**
3. Install it (it's free)

### 5. Start the app

In the same Command Prompt window, run:
```
npx expo start
```

A QR code will appear in your terminal.

### 6. Open on your iPhone

1. Make sure your **iPhone and Windows PC are on the same Wi-Fi network**
2. Open your **iPhone camera** and point it at the QR code on your computer screen
3. Tap the notification that says "Open in Expo Go"
4. The app will load on your phone!

### 7. Grant permissions

When the app opens, tap **Allow** for:
- Camera access
- Location access
- Photo Library access (when saving your first photo)

## How to Use

1. Point your camera — you'll see live overlays (map, compass, GPS info, Vaughan logo)
2. Tap the **white circle button** to capture
3. The photo is saved to your Photos with all overlays baked in
4. Tap **Share** to send it, or **Done** to go back to the camera

## Troubleshooting

| Problem | Solution |
|---------|----------|
| QR code won't scan | In the terminal, press `s` to switch to "Tunnel" mode, then scan the new QR code |
| "Network request failed" | Make sure iPhone and PC are on the same Wi-Fi |
| App crashes on open | Run `npm install` again, then `npx expo start --clear` |
| Location shows as "—" | Check iPhone Settings > Privacy > Location Services is ON |
| Map doesn't load | Give it a few seconds — satellite tiles take a moment to download |

## Project Structure

```
├── App.js                          # App entry point
├── app.json                        # Expo configuration
├── package.json                    # Dependencies
├── src/
│   ├── screens/
│   │   └── CameraScreen.js        # Main camera UI + capture logic
│   ├── components/
│   │   ├── MapThumbnail.js         # Satellite map overlay (Apple Maps)
│   │   ├── CompassRose.js          # SVG compass rose widget
│   │   ├── InfoOverlay.js          # Date/GPS/address text panel
│   │   └── VaughanLogo.js          # City of Vaughan branding
│   └── utils/
│       └── formatLocation.js       # DMS formatting, cardinal directions
└── ClarityCam/                     # (Native Swift version for Mac users)
```
