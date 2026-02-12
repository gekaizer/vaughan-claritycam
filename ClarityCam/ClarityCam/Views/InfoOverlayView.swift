import SwiftUI

struct InfoOverlayView: View {
    let dateTime: String
    let latitude: String
    let longitude: String
    let heading: String
    let address: String
    let cityProvincePostal: String
    let country: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            Text(dateTime)
                .fontWeight(.semibold)
            Text(latitude)
            Text(longitude)
            Text(heading)
            Divider()
                .background(Color.white)
                .frame(width: 160)
            Text(address)
                .fontWeight(.semibold)
            Text(cityProvincePostal)
            Text(country)
        }
        .font(.system(size: 11, design: .monospaced))
        .foregroundColor(.white)
        .shadow(color: .black, radius: 2, x: 1, y: 1)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.55))
        )
    }
}
