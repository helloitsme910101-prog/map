import SwiftUI

struct SearchResultsView: View {
    let query: String
    let results: [SearchResult]
    let isLoading: Bool
    let onSelect: (SearchResult) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if query.trimmingCharacters(in: .whitespaces).isEmpty {
                    suggestions
                } else if results.isEmpty && !isLoading {
                    ContentUnavailableView("No results",
                                           systemImage: "magnifyingglass",
                                           description: Text("Try a town, a street or a saved place."))
                        .padding(.top, 40)
                } else {
                    ForEach(results) { result in
                        SearchResultCard(result: result) { onSelect(result) }
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular in Kosovo")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
            ForEach(KosovoGazetteer.featured, id: \.title) { town in
                let result = SearchResult(id: "featured-\(town.title)",
                                          title: town.title,
                                          subtitle: "\(town.title), Kosovo",
                                          coordinate: town.coordinate,
                                          kind: .city,
                                          symbol: "building.2.fill")
                SearchResultCard(result: result) { onSelect(result) }
            }
        }
    }
}

struct SearchResultCard: View {
    let result: SearchResult
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: result.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(result.kind.tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(result.title)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1)
                    Text(result.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Label(result.coordinateText, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityElement(children: .combine)
    }
}
