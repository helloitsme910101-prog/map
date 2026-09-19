import SwiftUI

struct PlaceCard: View {
    let place: SavedPlace

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(.headline, design: .rounded))
                    .lineLimit(1)
                Text("\(place.category.emoji) \(place.category.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(place.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 44)   // room for the menu button
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var thumbnail: some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        if let data = place.photoData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(shape)
        } else {
            Image(systemName: place.category.symbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(place.category.color.gradient, in: shape)
        }
    }
}
