import SwiftUI

/// Appears above the tab bar after tapping the map.
struct DropCard: View {
    let pin: DroppedPin
    let onSave: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(pin.name ?? "Dropped pin")
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(2)
                    Label(String(format: "%.4f°, %.4f°", pin.coordinate.latitude, pin.coordinate.longitude),
                          systemImage: "mappin")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Dismiss")
            }

            Button {
                Haptics.tap()
                onSave()
            } label: {
                Label("Save This Place", systemImage: "heart.fill")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .padding(.leading, 18)
        .padding(.trailing, 8)
        .padding(.vertical, 12)
        .padding(.trailing, 10)
        .glass(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
