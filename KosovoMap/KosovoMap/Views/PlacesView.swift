import SwiftUI
import SwiftData

struct PlacesView: View {
    let places: [SavedPlace]
    let onOpen: (SavedPlace) -> Void
    let onEdit: (SavedPlace) -> Void

    @Environment(\.modelContext) private var context
    @State private var filter: PlaceCategory?
    @State private var pendingDelete: SavedPlace?

    private var visible: [SavedPlace] {
        guard let filter else { return places }
        return places.filter { $0.category == filter }
    }

    var body: some View {
        NavigationStack {
            Group {
                if places.isEmpty {
                    ContentUnavailableView("No saved places yet",
                                           systemImage: "mappin.and.ellipse",
                                           description: Text("Tap anywhere on the map, then choose Save This Place."))
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            filterChips
                            LazyVStack(spacing: 12) {
                                ForEach(visible) { place in row(place) }
                            }
                            if visible.isEmpty {
                                Text("Nothing in \(filter?.title ?? "this category") yet.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 30)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .animation(.snappy(duration: 0.25), value: filter)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 76) }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Saved")
            .confirmationDialog("Delete this place?",
                                isPresented: Binding(get: { pendingDelete != nil },
                                                     set: { if !$0 { pendingDelete = nil } }),
                                titleVisibility: .visible) {
                Button("Delete Place", role: .destructive) {
                    if let place = pendingDelete {
                        context.delete(place)
                        try? context.save()
                        Haptics.warning()
                    }
                    pendingDelete = nil
                }
                Button("Cancel", role: .cancel) { pendingDelete = nil }
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", emoji: nil, isOn: filter == nil) { filter = nil }
                ForEach(PlaceCategory.allCases) { category in
                    chip(title: category.title, emoji: category.emoji, isOn: filter == category) {
                        filter = (filter == category) ? nil : category
                    }
                }
            }
        }
    }

    private func chip(title: String, emoji: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.select()
            action()
        } label: {
            HStack(spacing: 5) {
                if let emoji { Text(emoji) }
                Text(title).font(.system(.subheadline, design: .rounded).weight(.semibold))
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 40)
            .foregroundStyle(isOn ? Color.white : Color.primary)
            .background(isOn ? AnyShapeStyle(Theme.cobalt) : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                        in: Capsule())
        }
        .buttonStyle(PressScaleStyle())
    }

    private func row(_ place: SavedPlace) -> some View {
        ZStack(alignment: .trailing) {
            Button { onOpen(place) } label: { PlaceCard(place: place) }
                .buttonStyle(PressScaleStyle())

            Menu {
                Button("Show on Map", systemImage: "map") { onOpen(place) }
                Button("Edit", systemImage: "pencil") { onEdit(place) }
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive) { pendingDelete = place }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel("More for \(place.name)")
        }
    }
}
