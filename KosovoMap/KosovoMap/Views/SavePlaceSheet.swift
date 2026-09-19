import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation

/// Used both to save a new place and to edit an existing one.
struct SavePlaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(NetworkMonitor.self) private var network
    @Environment(MapManager.self) private var mapManager
    @Environment(SearchManager.self) private var search

    private let existing: SavedPlace?
    private let coordinate: CLLocationCoordinate2D

    @State private var name: String
    @State private var category: PlaceCategory
    @State private var notes: String
    @State private var date: Date
    @State private var photoData: Data?
    @State private var pickerItem: PhotosPickerItem?
    @State private var confirmDelete = false

    init(pin: DroppedPin) {
        existing = nil
        coordinate = pin.coordinate
        _name = State(initialValue: pin.name ?? "")
        _category = State(initialValue: .other)
        _notes = State(initialValue: "")
        _date = State(initialValue: .now)
        _photoData = State(initialValue: nil)
    }

    init(place: SavedPlace) {
        existing = place
        coordinate = place.coordinate
        _name = State(initialValue: place.name)
        _category = State(initialValue: place.category)
        _notes = State(initialValue: place.notes)
        _date = State(initialValue: place.date)
        _photoData = State(initialValue: place.photoData)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    photoCard

                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Place name", text: $name)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                        Label(String(format: "%.4f°, %.4f°", coordinate.latitude, coordinate.longitude),
                              systemImage: "mappin")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardBackground()

                    categoryCard

                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .padding(.horizontal, 16)
                        .frame(minHeight: 52)
                        .cardBackground()

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardBackground()

                    if existing != nil {
                        Button(role: .destructive) { confirmDelete = true } label: {
                            Label("Delete Place", systemImage: "trash")
                                .frame(maxWidth: .infinity, minHeight: 50)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .padding(.top, 4)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(existing == nil ? "Save This Place" : "Edit Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).fontWeight(.semibold)
                }
            }
            .confirmationDialog("Delete this place?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete Place", role: .destructive, action: delete)
                Button("Cancel", role: .cancel) {}
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    withAnimation(.snappy) { photoData = StorageManager.downsized(data) }
                }
            }
        }
        .task {
            // Suggest a name for brand-new pins when online.
            guard existing == nil, name.isEmpty, network.isOnline else { return }
            if let suggestion = await search.reverse(coordinate), name.isEmpty { name = suggestion }
        }
    }

    // MARK: Pieces

    private var photoCard: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            ZStack {
                if let photoData, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 170)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(alignment: .bottomTrailing) {
                            Label("Change", systemImage: "photo")
                                .font(.footnote.weight(.semibold))
                                .padding(.horizontal, 12)
                                .frame(minHeight: 34)
                                .glass(Capsule())
                                .padding(10)
                        }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus").font(.system(size: 26))
                        Text("Add Photo").font(.system(.subheadline, design: .rounded).weight(.semibold))
                    }
                    .foregroundStyle(Theme.cobalt)
                    .frame(maxWidth: .infinity, minHeight: 110)
                }
            }
            .cardBackground()
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        }
        .accessibilityLabel(photoData == nil ? "Add photo" : "Change photo")
    }

    private var categoryCard: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
            ForEach(PlaceCategory.allCases) { item in
                Button {
                    Haptics.select()
                    withAnimation(.snappy(duration: 0.2)) { category = item }
                } label: {
                    HStack(spacing: 6) {
                        Text(item.emoji)
                        Text(item.title).font(.system(.subheadline, design: .rounded).weight(.semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .foregroundStyle(category == item ? Color.white : Color.primary)
                    .background(category == item ? AnyShapeStyle(item.color.gradient) : AnyShapeStyle(Color(.tertiarySystemFill)),
                                in: Capsule())
                }
                .buttonStyle(PressScaleStyle())
                .accessibilityAddTraits(category == item ? .isSelected : [])
            }
        }
        .padding(12)
        .cardBackground()
    }

    // MARK: Actions

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? "Untitled place" : trimmed

        if let place = existing {
            place.name = finalName
            place.category = category
            place.notes = notes
            place.date = date
            place.photoData = photoData
        } else {
            context.insert(SavedPlace(name: finalName, category: category, notes: notes,
                                      coordinate: coordinate, date: date, photoData: photoData))
            withAnimation(.snappy) { mapManager.clearPin() }
        }
        try? context.save()
        Haptics.success()
        dismiss()
    }

    private func delete() {
        if let place = existing {
            context.delete(place)
            try? context.save()
            Haptics.warning()
        }
        dismiss()
    }
}
