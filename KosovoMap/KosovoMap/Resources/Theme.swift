import SwiftUI

/// KosovoMap identity: flag cobalt as the accent, flag gold for saved things.
enum Theme {
    static let cobalt = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.44, green: 0.60, blue: 1.00, alpha: 1)
            : UIColor(red: 0.141, green: 0.290, blue: 0.647, alpha: 1)
    })
    static let gold = Color(red: 0.816, green: 0.651, blue: 0.314)
    static let online = Color(red: 0.20, green: 0.78, blue: 0.45)
    static let offline = Color(red: 1.00, green: 0.62, blue: 0.10)

    static let cardRadius: CGFloat = 22
}

extension View {
    /// Solid grouped card used inside sheets and lists.
    func cardBackground() -> some View {
        background(Color(.secondarySystemGroupedBackground),
                   in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
    }
}
