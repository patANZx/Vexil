import SwiftUI

// TODO: Dev Docs
struct FlagConfiguration<Value: FlagValue>: FlagPoleItem {

    let wigwag: FlagWigwag<Value>

    var name: String {
        wigwag.name
    }

    var keyPath: FlagKeyPath {
        wigwag.keyPath
    }

    var isVisible: Bool {
        wigwag.displayOption != .hidden
    }

    var children: [any FlagPoleItem]? { nil }

    func makeContent() -> any View {
        FlagControl(wigwag)
    }

}


struct FlagContent<Value: FlagValue>: View {

    var configuration: FlagConfiguration<Value>

    @State private var isShowingDetail = false
    @FocusState private var isFocused


    var body: some View {
        FlagView(configuration.wigwag) { context in

        }
    }

}
