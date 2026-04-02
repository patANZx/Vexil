import SwiftUI

// TODO: Dev Docs
struct FlagGroupConfiguration<Value: FlagContainer>: FlagPoleItem {

    let wigwag: FlagGroupWigwag<Value>
    let items: [any FlagPoleItem]

    var isVisible: Bool {
        wigwag.displayOption != .hidden && items.contains(where: \.isVisible)
    }

    var keyPath: FlagKeyPath {
        wigwag.keyPath
    }

    var name: String {
        wigwag.name
    }

    var children: [any FlagPoleItem]? {
        items
    }

    var visibleItems: [any FlagPoleItem] {
        wigwag.displayOption != .hidden ? items.filter(\.isVisible) : []
    }

    func makeContent() -> any View {
        FlagGroupContent(configuration: self)
    }

}

struct FlagGroupContent<Value: FlagContainer>: View {

    var configuration: FlagGroupConfiguration<Value>

    var body: some View {
        switch configuration.wigwag.displayOption {
        case _ where configuration.isVisible == false:
            EmptyView()

        case .section:
            Section(configuration.name) {
                ForEach(configuration.visibleItems, id: \.keyPath, content: FlagPoleItemContent.init)
            }

        default:
            FlagNavigationLink(configuration: configuration)
        }
    }

}

// TODO: Dev Docs
private struct FlagNavigationLink<Value: FlagContainer>: View {

    var configuration: FlagGroupConfiguration<Value>

    @Environment(\.flagPoleContext) private var flagPoleContext
    @Environment(\.flagControlStyles) private var flagControlStyles

    var body: some View {
        NavigationLink(configuration.name) {
            List {
                if let description = configuration.wigwag.description {
                    Section {
                        Text(description)
                    }
                }
                ForEach(configuration.visibleItems, id: \.keyPath, content: FlagPoleItemContent.init)
            }
            .environment(\.flagPoleContext, flagPoleContext)
            .environment(\.flagControlStyles, flagControlStyles)
        }
    }

}
