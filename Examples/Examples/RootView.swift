import SwiftUI
import Vexillographer

struct RootView: View {
    var body: some View {
        NavigationStack {
            Vexillographer()
                .flagPole(
                    Dependencies.current.flags,
                    editableSource: Dependencies.current.flags._sources.first
                )
        }
//        .task {
//            do {
//                for value in 0... {
//                    try await Task.sleep(for: .seconds(1))
//                    try RemoteFlags.values.setFlagValue(value, key: "number")
//                }
//            } catch { }
//        }
    }
}

#Preview {
    RootView()
}
