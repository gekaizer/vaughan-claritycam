import SwiftUI
import MapKit

struct MapThumbnailView: View {
    let coordinate: CLLocationCoordinate2D?

    var body: some View {
        Group {
            if let coordinate = coordinate {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))) {
                    Marker("", coordinate: coordinate)
                        .tint(.red)
                }
                .mapStyle(.imagery)
                .disabled(true)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 2)
                )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.5))
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
            }
        }
    }
}
