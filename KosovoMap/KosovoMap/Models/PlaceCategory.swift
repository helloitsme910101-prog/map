import SwiftUI

enum PlaceCategory: String, CaseIterable, Identifiable {
    case food, gym, cars, shopping, friends, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food: "Food"
        case .gym: "Gym"
        case .cars: "Cars"
        case .shopping: "Shopping"
        case .friends: "Friends"
        case .other: "Other"
        }
    }

    var emoji: String {
        switch self {
        case .food: "🍔"
        case .gym: "🏋️"
        case .cars: "🚗"
        case .shopping: "🛍️"
        case .friends: "👥"
        case .other: "📍"
        }
    }

    var symbol: String {
        switch self {
        case .food: "fork.knife"
        case .gym: "dumbbell.fill"
        case .cars: "car.fill"
        case .shopping: "bag.fill"
        case .friends: "person.2.fill"
        case .other: "mappin"
        }
    }

    var color: Color {
        switch self {
        case .food: Color(red: 0.96, green: 0.55, blue: 0.20)
        case .gym: Color(red: 0.87, green: 0.25, blue: 0.33)
        case .cars: Color(red: 0.36, green: 0.40, blue: 0.52)
        case .shopping: Color(red: 0.66, green: 0.36, blue: 0.85)
        case .friends: Color(red: 0.16, green: 0.66, blue: 0.62)
        case .other: Color(red: 0.141, green: 0.290, blue: 0.647)
        }
    }

    var uiColor: UIColor { UIColor(color) }
}
