import SwiftUI
import CoreLocation
import Photos

struct CameraView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var locationManager = LocationManager()

    @State private var isSaving = false
    @State private var showSavedAlert = false
    @State private var showPreview = false
    @State private var previewImage: UIImage?
    @State private var flashTrigger = false

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        return df
    }()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if cameraService.isAuthorized {
                // Camera preview
                CameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea()

                // Live overlay elements
                overlayElements

                // Flash effect
                if flashTrigger {
                    Color.white
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                // Capture button
                VStack {
                    Spacer()
                    captureButton
                        .padding(.bottom, 40)
                }
            } else {
                permissionView
            }

            // Saved confirmation
            if showSavedAlert {
                savedConfirmation
            }
        }
        .onAppear {
            locationManager.requestPermission()
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
            locationManager.stopUpdating()
        }
        .fullScreenCover(isPresented: $showPreview) {
            if let image = previewImage {
                PhotoPreviewView(image: image, isPresented: $showPreview)
            }
        }
    }

    // MARK: - Overlay Elements

    private var overlayElements: some View {
        GeometryReader { geo in
            ZStack {
                // Top-left: Map thumbnail
                VStack {
                    HStack {
                        MapThumbnailView(coordinate: locationManager.location?.coordinate)
                            .frame(width: 130, height: 130)
                            .padding(.leading, 12)
                            .padding(.top, 50)
                        Spacer()
                    }
                    Spacer()
                }

                // Top-right: Info text
                VStack {
                    HStack {
                        Spacer()
                        InfoOverlayView(
                            dateTime: dateFormatter.string(from: Date()),
                            latitude: locationManager.latitudeString,
                            longitude: locationManager.longitudeString,
                            heading: locationManager.headingString,
                            address: locationManager.addressString,
                            cityProvincePostal: locationManager.cityProvincePostalString,
                            country: locationManager.countryString
                        )
                        .padding(.trailing, 12)
                        .padding(.top, 50)
                    }
                    Spacer()
                }

                // Bottom-left: Compass
                VStack {
                    Spacer()
                    HStack {
                        CompassRoseView(heading: locationManager.heading?.trueHeading ?? 0)
                            .frame(width: 90, height: 90)
                            .padding(.leading, 12)
                            .padding(.bottom, 110)
                        Spacer()
                    }
                }

                // Bottom-right: Vaughan logo
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VaughanLogoView()
                            .padding(.trailing, 16)
                            .padding(.bottom, 110)
                    }
                }
            }
        }
    }

    // MARK: - Capture Button

    private var captureButton: some View {
        Button(action: capturePhoto) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 72, height: 72)
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
            }
        }
        .disabled(isSaving)
    }

    // MARK: - Permission View

    private var permissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Camera Access Required")
                .font(.title2)
                .foregroundColor(.white)
            Text("ClarityCam needs camera and location access to stamp photos with GPS data.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Saved Confirmation

    private var savedConfirmation: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Photo Saved")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.7))
            )
            .padding(.bottom, 130)
        }
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showSavedAlert = false }
            }
        }
    }

    // MARK: - Capture Logic

    private func capturePhoto() {
        isSaving = true

        // Flash effect
        withAnimation(.easeInOut(duration: 0.1)) { flashTrigger = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.1)) { flashTrigger = false }
        }

        let overlayData = ImageCompositor.OverlayData(
            dateTime: dateFormatter.string(from: Date()),
            latitude: locationManager.latitudeString,
            longitude: locationManager.longitudeString,
            heading: locationManager.headingString,
            address: locationManager.addressString,
            cityProvincePostal: locationManager.cityProvincePostalString,
            country: locationManager.countryString,
            headingDegrees: locationManager.heading?.trueHeading ?? 0,
            coordinate: locationManager.location?.coordinate
        )

        cameraService.capturePhoto { image in
            guard let image = image else {
                isSaving = false
                return
            }

            Task {
                let composited = await ImageCompositor.composite(image: image, overlayData: overlayData)

                // Save to photo library
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    if status == .authorized {
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetChangeRequest.creationRequestForAsset(from: composited)
                        } completionHandler: { success, error in
                            DispatchQueue.main.async {
                                isSaving = false
                                previewImage = composited
                                if success {
                                    withAnimation { showSavedAlert = true }
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            isSaving = false
                            previewImage = composited
                            showPreview = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Photo Preview

struct PhotoPreviewView: View {
    let image: UIImage
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()

                HStack(spacing: 40) {
                    // Share button
                    Button(action: shareImage) {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                            Text("Share")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }

                    // Done
                    Button(action: { isPresented = false }) {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 24))
                            Text("Done")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func shareImage() {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
