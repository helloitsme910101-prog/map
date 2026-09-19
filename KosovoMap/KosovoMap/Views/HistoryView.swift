import SwiftUI

/// Placeholder until step 2 (tracking, timeline, daily routes, heatmap).
struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Location History", systemImage: "clock.arrow.circlepath")
            } description: {
                Text("Nothing is recorded yet. Tracking, your daily timeline, routes and heatmap arrive in step 2. When they do, everything stays on this iPhone.")
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
        }
    }
}
