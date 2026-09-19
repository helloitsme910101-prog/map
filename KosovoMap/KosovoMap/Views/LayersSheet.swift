import SwiftUI

struct LayersSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("mapStyle") private var mapStyle: MapStyleChoice = .clean
    @AppStorage("show3D") private var show3D = false
    @AppStorage("mapMode") private var mapMode: MapMode = .auto

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section("Map Style") {
                        HStack(spacing: 12) {
                            ForEach(MapStyleChoice.allCases) { style in
                                StyleTile(style: style, isSelected: mapStyle == style) {
                                    Haptics.select()
                                    withAnimation(.snappy(duration: 0.25)) { mapStyle = style }
                                }
                            }
                        }
                    }

                    Toggle(isOn: $show3D) {
                        Label("3D Buildings", systemImage: "cube.transparent")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 56)
                    .cardBackground()

                    section("Map Mode") {
                        MapModePicker(selection: $mapMode)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Layers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            content()
        }
    }
}

private struct StyleTile: View {
    let style: MapStyleChoice
    let isSelected: Bool
    let action: () -> Void

    private var swatch: [Color] {
        style == .clean
            ? [Color(white: 0.95), Color(white: 0.80)]
            : [Color(red: 0.76, green: 0.88, blue: 0.70), Color(red: 0.62, green: 0.79, blue: 0.93)]
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: swatch, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 74)
                    .overlay(alignment: .bottomTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white, Theme.cobalt)
                                .padding(8)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(style.title).font(.system(.subheadline, design: .rounded).weight(.semibold))
                    Text(style.detail).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .cardBackground()
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .strokeBorder(isSelected ? Theme.cobalt : .clear, lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
