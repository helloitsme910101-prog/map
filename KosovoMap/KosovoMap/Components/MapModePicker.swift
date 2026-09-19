import SwiftUI

struct MapModePicker: View {
    @Binding var selection: MapMode

    var body: some View {
        VStack(spacing: 0) {
            ForEach(MapMode.allCases) { mode in
                Button {
                    Haptics.select()
                    withAnimation(.snappy(duration: 0.25)) { selection = mode }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: mode.symbol)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.cobalt)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mode.title).font(.system(.body, design: .rounded).weight(.semibold))
                            Text(mode.detail).font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        if selection == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.cobalt)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == mode ? .isSelected : [])

                if mode != MapMode.allCases.last {
                    Divider().padding(.leading, 60)
                }
            }
        }
        .cardBackground()
    }
}
