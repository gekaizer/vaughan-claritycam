# ClarityCam - City of Vaughan Geo-Stamped Camera

An iPhone camera app that captures photos with location metadata overlays for the City of Vaughan.

## Features

- **Live Camera Preview** with real-time overlay display
- **GPS Coordinates** in degrees/minutes/seconds format
- **Reverse Geocoding** — street address, city, province, postal code, country
- **Compass Heading** with cardinal direction
- **Satellite Map Thumbnail** showing current location
- **Compass Rose Widget** with live heading indicator
- **City of Vaughan Branding**
- **Auto-save** to photo library with all overlays composited into the image
- **Share** composited photos directly from the app

## Requirements

- iOS 17.0+
- Xcode 15.0+
- iPhone with camera, GPS, and compass

## Setup

1. Open `ClarityCam/ClarityCam.xcodeproj` in Xcode
2. Select your development team under Signing & Capabilities
3. Build and run on a physical iPhone (camera requires a real device)

## Permissions

The app requests the following permissions:
- **Camera** — to capture photos
- **Location (When In Use)** — for GPS coordinates, address, and compass heading
- **Photo Library (Add Only)** — to save stamped photos

## Architecture

```
ClarityCam/
├── ClarityCamApp.swift          # App entry point
├── Views/
│   ├── CameraView.swift         # Main camera UI with overlays
│   ├── CameraPreviewView.swift  # AVCaptureSession preview wrapper
│   ├── MapThumbnailView.swift   # Satellite map overlay (MapKit)
│   ├── CompassRoseView.swift    # Compass rose widget
│   ├── InfoOverlayView.swift    # Date/GPS/address text overlay
│   └── VaughanLogoView.swift    # City of Vaughan branding
├── Services/
│   ├── CameraService.swift      # Camera capture management
│   ├── LocationManager.swift    # GPS, geocoding, compass
│   └── ImageCompositor.swift    # Composites overlays onto captured photo
└── Assets.xcassets/
```
