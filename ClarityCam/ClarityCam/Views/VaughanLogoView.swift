import SwiftUI

struct VaughanLogoView: View {
    var body: some View {
        VStack(spacing: 2) {
            // Stylized "V" mark
            ZStack {
                // Shield shape
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.35, blue: 0.65),
                                     Color(red: 0.0, green: 0.25, blue: 0.50)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )

                // "V" letter
                Text("V")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(.white)
            }

            Text("VAUGHAN")
                .font(.system(size: 10, weight: .bold, design: .default))
                .tracking(2)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 1, y: 1)

            Text("ClarityCam")
                .font(.system(size: 8, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .black, radius: 2, x: 1, y: 1)
        }
    }
}
