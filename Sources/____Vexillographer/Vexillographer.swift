import SwiftUI

// TODO: Docs
public struct Vexillographer<RootGroup: FlagContainer>: View {

    private var flagPole: FlagPole<RootGroup>
    private var editableSource: (any FlagValueSource)?

    // FIX: Should this be opt-in?
    @State private var searchText = ""

    // TODO: Docs
    public init(flagPole: FlagPole<RootGroup>, editableSource: (any FlagValueSource)?) {
        self.flagPole = flagPole
        self.editableSource = editableSource
    }

    public var body: some View {
        FlagList(searchText: searchText)
            .searchable(text: $searchText)
            .flagPole(flagPole, editableSource: editableSource)
    }

}

private struct FlagList: View {

    var searchText: String

    @Environment(\.flagPoleContext) private var flagPoleContext
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        List {
            if flagPoleContext.flagPoleID == nil {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)

            } else if flagPoleContext.visibleItems.isEmpty {
                Text("No Flags")
                    .frame(maxWidth: .infinity)
                    .font(.title2.weight(.semibold))

            } else if isSearching {
                let matchingFlags = flagPoleContext.flags(matching: searchText)
                if matchingFlags.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView.search(text: searchText)
                            .listRowBackground(Color.clear)
                    } else {
                        Text("No Results")
                            .frame(maxWidth: .infinity)
                            .font(.title2.weight(.semibold))
                    }
                } else {
                    ForEach(matchingFlags, id: \.keyPath, content: FlagPoleItemContent.init)
                }

            } else {
                ForEach(flagPoleContext.visibleItems, id: \.keyPath, content: FlagPoleItemContent.init)
            }
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#endif
    }

}

extension FlagPoleItem {

    func matches(searchText: String) -> Bool {
        searchText.isEmpty || name.localizedStandardContains(searchText) || keyPath.key.localizedStandardContains(searchText)
    }

    func flags(matching searchText: String) -> [any FlagPoleItem] {
        guard isVisible else {
            return []
        }
        if let children {
            return children.flatMap { $0.flags(matching: searchText) }
        } else if matches(searchText: searchText) {
            return [self]
        } else {
            return []
        }
    }

}

extension FlagPoleContext {

    var visibleItems: [any FlagPoleItem] {
        items.filter(\.isVisible)
    }

    func flags(matching searchText: String) -> [any FlagPoleItem] {
        items.flatMap { $0.flags(matching: searchText) }
    }

}
