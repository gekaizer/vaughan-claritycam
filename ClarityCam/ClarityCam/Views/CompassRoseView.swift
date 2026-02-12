import SwiftUI

struct CompassRoseView: View {
    let heading: Double

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.black.opacity(0.5))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                )

            // Cardinal direction labels
            ForEach(compassPoints, id: \.label) { point in
                Text(point.label)
                    .font(.system(size: point.isPrimary ? 12 : 8, weight: .bold))
                    .foregroundColor(point.label == "N" ? .red : .white)
                    .offset(y: point.isPrimary ? -32 : -30)
                    .rotationEffect(.degrees(point.angle))
            }

            // Tick marks
            ForEach(0..<36, id: \.self) { i in
                Rectangle()
                    .fill(Color.white.opacity(i % 9 == 0 ? 1.0 : 0.4))
                    .frame(width: i % 9 == 0 ? 2 : 1,
                           height: i % 9 == 0 ? 10 : 5)
                    .offset(y: -40)
                    .rotationEffect(.degrees(Double(i) * 10))
            }

            // Heading needle
            VStack(spacing: 0) {
                Triangle()
                    .fill(Color.red)
                    .frame(width: 10, height: 18)
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2, height: 8)
            }
            .offset(y: -12)

            // South needle
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: 8)
                Triangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 10, height: 18)
                    .rotationEffect(.degrees(180))
            }
            .offset(y: 12)

            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
        }
        .rotationEffect(.degrees(-heading))
        .frame(width: 90, height: 90)
    }

    private var compassPoints: [CompassPoint] {
        [
            CompassPoint(label: "N", angle: 0, isPrimary: true),
            CompassPoint(label: "E", angle: 90, isPrimary: true),
            CompassPoint(label: "S", angle: 180, isPrimary: true),
            CompassPoint(label: "W", angle: 270, isPrimary: true),
        ]
    }
}

struct CompassPoint {
    let label: String
    let angle: Double
    let isPrimary: Bool
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
