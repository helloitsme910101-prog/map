import SwiftUI

struct FloatingTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    guard selection != tab else { return }
                    Haptics.select()
                    withAnimation(.snappy(duration: 0.3)) { selection = tab }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 19, weight: .semibold))
                        Text(tab.title)
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                    }
                    .foregroundStyle(selection == tab ? Theme.cobalt : Color.secondary)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background {
                        if selection == tab {
                            Capsule()
                                .fill(Theme.cobalt.opacity(0.14))
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(6)
        .glass(Capsule())
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }
}
