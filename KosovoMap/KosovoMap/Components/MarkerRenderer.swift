import UIKit

/// Draws map pins: a coloured teardrop with a white ring and an SF Symbol.
enum MarkerRenderer {
    static func pin(color: UIColor, symbol: String) -> UIImage {
        let size = CGSize(width: 44, height: 56)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            let head = CGRect(x: 4, y: 2, width: 36, height: 36)

            let tail = UIBezierPath()
            tail.move(to: CGPoint(x: 22, y: 55))
            tail.addLine(to: CGPoint(x: 13, y: 33))
            tail.addLine(to: CGPoint(x: 31, y: 33))
            tail.close()

            c.setShadow(offset: CGSize(width: 0, height: 2), blur: 4,
                        color: UIColor.black.withAlphaComponent(0.30).cgColor)
            color.setFill()
            tail.fill()
            UIBezierPath(ovalIn: head).fill()
            c.setShadow(offset: .zero, blur: 0, color: nil)

            UIColor.white.setStroke()
            let ring = UIBezierPath(ovalIn: head.insetBy(dx: 1.5, dy: 1.5))
            ring.lineWidth = 3
            ring.stroke()

            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            if let glyph = UIImage(systemName: symbol, withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                let s = glyph.size
                glyph.draw(in: CGRect(x: head.midX - s.width / 2, y: head.midY - s.height / 2,
                                      width: s.width, height: s.height))
            }
        }
    }
}
