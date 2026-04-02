import SwiftUI

struct RootView: View {

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                content
            }
        } else {
            NavigationView {
                content
            }
        }
    }

    var content: some View {
        Form {
            Section {
                NavigationLink("Basic") {
                    BasicExample()
                }
            }
            Section {
                NavigationLink("Advanced") {
                    Text("Advanced")
                }
                NavigationLink("Custom") {
                    Text("Custom")
                }
            }
        }
        .navigationTitle("Examples")
    }

}

#Preview {
    RootView()
}
