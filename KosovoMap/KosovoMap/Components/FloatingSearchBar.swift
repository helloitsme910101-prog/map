import SwiftUI

struct FloatingSearchBar: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    var isLoading: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField("Search places, streets or cities", text: $text)
                .focused(focused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .font(.system(.body, design: .rounded))

            if isLoading {
                ProgressView().controlSize(.small)
            }

            if !text.isEmpty {
                Button {
                    text = ""
                    Haptics.tap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Clear search")
            }

            if focused.wrappedValue {
                Button("Cancel") {
                    text = ""
                    focused.wrappedValue = false
                }
                .font(.system(.body, design: .rounded).weight(.medium))
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 54)
        .glass(Capsule())
        .animation(.snappy(duration: 0.25), value: focused.wrappedValue)
        .animation(.snappy(duration: 0.2), value: text.isEmpty)
    }
}
