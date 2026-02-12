import UIKit
import SwiftUI
import MapKit

class ImageCompositor {

    struct OverlayData {
        let dateTime: String
        let latitude: String
        let longitude: String
        let heading: String
        let address: String
        let cityProvincePostal: String
        let country: String
        let headingDegrees: Double
        let coordinate: CLLocationCoordinate2D?
    }

    /// Composites all overlay elements onto the captured photo
    @MainActor
    static func composite(image: UIImage, overlayData: OverlayData) async -> UIImage {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)

        // Generate map snapshot if coordinate available
        let mapImage = await generateMapSnapshot(coordinate: overlayData.coordinate, size: CGSize(width: 300, height: 300))

        let result = renderer.image { context in
            // Draw the original photo
            image.draw(at: .zero)

            let ctx = context.cgContext
            let scale = size.width / 390.0 // Scale relative to standard iPhone width

            // --- Top-Left: Map Thumbnail ---
            if let mapImage = mapImage {
                let mapSize = CGSize(width: 140 * scale, height: 140 * scale)
                let mapRect = CGRect(x: 16 * scale, y: 50 * scale, width: mapSize.width, height: mapSize.height)

                let clipPath = UIBezierPath(roundedRect: mapRect, cornerRadius: 10 * scale)
                ctx.saveGState()
                clipPath.addClip()
                mapImage.draw(in: mapRect)
                ctx.restoreGState()

                // Border
                ctx.setStrokeColor(UIColor.white.cgColor)
                ctx.setLineWidth(3 * scale)
                clipPath.stroke()
            }

            // --- Top-Right: Info Text ---
            drawInfoText(in: ctx, size: size, scale: scale, data: overlayData)

            // --- Bottom-Left: Compass Rose ---
            drawCompassRose(in: ctx, size: size, scale: scale, heading: overlayData.headingDegrees)

            // --- Bottom-Right: Vaughan Logo ---
            drawVaughanLogo(in: ctx, size: size, scale: scale)
        }

        return result
    }

    // MARK: - Map Snapshot

    private static func generateMapSnapshot(coordinate: CLLocationCoordinate2D?, size: CGSize) async -> UIImage? {
        guard let coordinate = coordinate else { return nil }

        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        )
        options.size = size
        options.mapType = .satellite

        let snapshotter = MKMapSnapshotter(options: options)
        do {
            let snapshot = try await snapshotter.start()
            // Draw a pin on the snapshot
            let finalImage = UIGraphicsImageRenderer(size: size).image { _ in
                snapshot.image.draw(at: .zero)
                let point = snapshot.point(for: coordinate)
                let pinSize: CGFloat = 20
                let pinRect = CGRect(x: point.x - pinSize/2, y: point.y - pinSize, width: pinSize, height: pinSize)
                // Simple red circle marker
                UIColor.red.setFill()
                let circle = UIBezierPath(ovalIn: CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12))
                circle.fill()
                UIColor.white.setStroke()
                circle.lineWidth = 2
                circle.stroke()
            }
            return finalImage
        } catch {
            print("Map snapshot error: \(error)")
            return nil
        }
    }

    // MARK: - Info Text Drawing

    private static func drawInfoText(in ctx: CGContext, size: CGSize, scale: CGFloat, data: OverlayData) {
        let padding: CGFloat = 16 * scale
        let lineHeight: CGFloat = 16 * scale
        let fontSize: CGFloat = 12 * scale

        let regularFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let boldFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)

        let lines: [(String, UIFont)] = [
            (data.dateTime, boldFont),
            (data.latitude, regularFont),
            (data.longitude, regularFont),
            (data.heading, regularFont),
            ("", regularFont), // spacer for divider
            (data.address, boldFont),
            (data.cityProvincePostal, regularFont),
            (data.country, regularFont),
        ]

        // Calculate background rect
        let textWidth: CGFloat = 220 * scale
        let textHeight = CGFloat(lines.count) * lineHeight + 20 * scale
        let bgRect = CGRect(
            x: size.width - textWidth - padding,
            y: 50 * scale,
            width: textWidth,
            height: textHeight
        )

        // Draw background
        ctx.saveGState()
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.55).cgColor)
        let bgPath = UIBezierPath(roundedRect: bgRect, cornerRadius: 8 * scale)
        bgPath.fill()
        ctx.restoreGState()

        // Draw text lines (right-aligned)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = CGSize(width: 1, height: 1)
        shadow.shadowBlurRadius = 2

        var y = bgRect.origin.y + 10 * scale

        for (text, font) in lines {
            if text.isEmpty {
                // Draw divider line
                ctx.saveGState()
                ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
                ctx.setLineWidth(1)
                ctx.move(to: CGPoint(x: bgRect.origin.x + 10 * scale, y: y + lineHeight / 2))
                ctx.addLine(to: CGPoint(x: bgRect.maxX - 10 * scale, y: y + lineHeight / 2))
                ctx.strokePath()
                ctx.restoreGState()
            } else {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.white,
                    .shadow: shadow
                ]
                let attrString = NSAttributedString(string: text, attributes: attributes)
                let textSize = attrString.size()
                let textX = bgRect.maxX - textSize.width - 10 * scale
                attrString.draw(at: CGPoint(x: textX, y: y))
            }
            y += lineHeight
        }
    }

    // MARK: - Compass Rose Drawing

    private static func drawCompassRose(in ctx: CGContext, size: CGSize, scale: CGFloat, heading: Double) {
        let compassSize: CGFloat = 90 * scale
        let centerX: CGFloat = 16 * scale + compassSize / 2
        let centerY: CGFloat = size.height - 16 * scale - compassSize / 2

        ctx.saveGState()
        ctx.translateBy(x: centerX, y: centerY)

        // Background circle
        let radius = compassSize / 2
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        ctx.fillEllipse(in: CGRect(x: -radius, y: -radius, width: compassSize, height: compassSize))
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.8).cgColor)
        ctx.setLineWidth(2 * scale)
        ctx.strokeEllipse(in: CGRect(x: -radius, y: -radius, width: compassSize, height: compassSize))

        // Rotate for heading
        let headingRad = -heading * .pi / 180
        ctx.rotate(by: headingRad)

        // Tick marks
        for i in 0..<36 {
            let angle = Double(i) * 10.0 * .pi / 180.0
            let isMajor = i % 9 == 0
            let tickLength: CGFloat = isMajor ? 10 * scale : 5 * scale
            let tickWidth: CGFloat = isMajor ? 2 * scale : 1 * scale
            let outerRadius = radius - 2 * scale
            let innerRadius = outerRadius - tickLength

            ctx.saveGState()
            ctx.rotate(by: angle)
            ctx.setStrokeColor(UIColor.white.withAlphaComponent(isMajor ? 1.0 : 0.4).cgColor)
            ctx.setLineWidth(tickWidth)
            ctx.move(to: CGPoint(x: 0, y: -innerRadius))
            ctx.addLine(to: CGPoint(x: 0, y: -outerRadius))
            ctx.strokePath()
            ctx.restoreGState()
        }

        // Cardinal labels
        let labels = [("N", 0.0, UIColor.red), ("E", 90.0, UIColor.white),
                      ("S", 180.0, UIColor.white), ("W", 270.0, UIColor.white)]
        let labelFont = UIFont.systemFont(ofSize: 11 * scale, weight: .bold)
        let labelRadius = radius - 18 * scale

        for (text, angle, color) in labels {
            let angleRad = angle * .pi / 180
            let x = labelRadius * sin(angleRad)
            let y = -labelRadius * cos(angleRad)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: color
            ]
            let attrString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attrString.size()
            attrString.draw(at: CGPoint(x: x - textSize.width / 2, y: y - textSize.height / 2))
        }

        // North needle (red triangle pointing up)
        ctx.setFillColor(UIColor.red.cgColor)
        ctx.move(to: CGPoint(x: 0, y: -20 * scale))
        ctx.addLine(to: CGPoint(x: -5 * scale, y: 0))
        ctx.addLine(to: CGPoint(x: 5 * scale, y: 0))
        ctx.closePath()
        ctx.fillPath()

        // South needle (white triangle pointing down)
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.6).cgColor)
        ctx.move(to: CGPoint(x: 0, y: 20 * scale))
        ctx.addLine(to: CGPoint(x: -5 * scale, y: 0))
        ctx.addLine(to: CGPoint(x: 5 * scale, y: 0))
        ctx.closePath()
        ctx.fillPath()

        // Center dot
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(x: -3 * scale, y: -3 * scale, width: 6 * scale, height: 6 * scale))

        ctx.restoreGState()
    }

    // MARK: - Vaughan Logo Drawing

    private static func drawVaughanLogo(in ctx: CGContext, size: CGSize, scale: CGFloat) {
        let logoWidth: CGFloat = 60 * scale
        let logoHeight: CGFloat = 75 * scale
        let padding: CGFloat = 16 * scale
        let logoX = size.width - logoWidth - padding
        let logoY = size.height - logoHeight - padding

        // Shield background
        let shieldRect = CGRect(x: logoX + 5 * scale, y: logoY, width: 50 * scale, height: 50 * scale)
        let shieldPath = UIBezierPath(roundedRect: shieldRect, cornerRadius: 6 * scale)

        // Gradient fill
        ctx.saveGState()
        shieldPath.addClip()
        let colors = [
            UIColor(red: 0, green: 0.35, blue: 0.65, alpha: 1).cgColor,
            UIColor(red: 0, green: 0.25, blue: 0.50, alpha: 1).cgColor
        ]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
        ctx.drawLinearGradient(gradient, start: shieldRect.origin, end: CGPoint(x: shieldRect.origin.x, y: shieldRect.maxY), options: [])
        ctx.restoreGState()

        // Shield border
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.8).cgColor)
        ctx.setLineWidth(1.5 * scale)
        shieldPath.stroke()

        // "V" text
        let vFont = UIFont(name: "Georgia-Bold", size: 30 * scale) ?? UIFont.systemFont(ofSize: 30 * scale, weight: .bold)
        let vAttributes: [NSAttributedString.Key: Any] = [
            .font: vFont,
            .foregroundColor: UIColor.white
        ]
        let vString = NSAttributedString(string: "V", attributes: vAttributes)
        let vSize = vString.size()
        vString.draw(at: CGPoint(
            x: shieldRect.midX - vSize.width / 2,
            y: shieldRect.midY - vSize.height / 2
        ))

        // "VAUGHAN" text
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = CGSize(width: 1, height: 1)
        shadow.shadowBlurRadius = 2

        let nameFont = UIFont.systemFont(ofSize: 9 * scale, weight: .bold)
        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: nameFont,
            .foregroundColor: UIColor.white,
            .kern: 2 * scale,
            .shadow: shadow
        ]
        let nameString = NSAttributedString(string: "VAUGHAN", attributes: nameAttrs)
        let nameSize = nameString.size()
        nameString.draw(at: CGPoint(
            x: shieldRect.midX - nameSize.width / 2,
            y: shieldRect.maxY + 4 * scale
        ))

        // "ClarityCam" text
        let subFont = UIFont.systemFont(ofSize: 7 * scale, weight: .medium)
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: subFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.8),
            .shadow: shadow
        ]
        let subString = NSAttributedString(string: "ClarityCam", attributes: subAttrs)
        let subSize = subString.size()
        subString.draw(at: CGPoint(
            x: shieldRect.midX - subSize.width / 2,
            y: shieldRect.maxY + 4 * scale + nameSize.height + 2 * scale
        ))
    }
}
