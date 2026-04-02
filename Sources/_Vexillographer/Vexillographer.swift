import SwiftUI
import Vexil

// This is the entry point...
public struct Vexillographer: View {

    @State private var searchText = ""

    public init() { }

    public var body: some View {
        FlagList(searchText: searchText)
            .searchable(text: $searchText)
    }

}

private struct FlagList: View {

    var searchText: String
//    @Environment(\.flagPoleContext) private var flagPoleContext
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject private var storage: FlagPoleContextStorage
    private var flagPoleContext: FlagPoleContext { storage.context }

    var body: some View {
        List {
            if isSearching {
                let searchResult = flagPoleContext.items(matching: searchText)
                ForEach(searchResult, id: \.keyPath, content: \.content)
            } else {
                if let header = flagPoleContext.header {
                    Section {
                        header
                    }
                }
                let visibleItems = flagPoleContext.items.filter { $0.isHidden == false }
                ForEach(visibleItems, id: \.keyPath, content: \.content)
                if let footer = flagPoleContext.footer {
                    Section {
                        footer
                    }
                }
            }
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#endif
    }

}

// What is Vexillographer?
// - A built in way to view and set flag values
// - it is similar to the settings app
// - can be used stand alone or as tab

// What is the core?
// - Some sort of environment flag pole thing
// - A way to interact with flags

// Examples
// - Just a simple app that uses Vexillographer as root or as navigation destination
