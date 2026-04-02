// Copyright © 2025 ANZ. All rights reserved.

import SwiftUI

protocol AnyVexillographerGroup: AnyVexillographerItem {

    var items: [any AnyVexillographerItem] { get set }

}

struct VexillographerGroup<Value: FlagContainer>: AnyVexillographerGroup {

    var group: FlagGroupWigwag<Value>
    var items = [any AnyVexillographerItem]()

    init(_ group: FlagGroupWigwag<Value>) {
        self.group = group
    }

    var name: String {
        group.name
    }

    var keyPath: FlagKeyPath {
        group.keyPath
    }

    var isHidden: Bool {
        group.displayOption == .hidden || visibleItems.isEmpty
    }

    var visibleItems: [any AnyVexillographerItem] {
        items.filter { $0.isHidden == false }
    }

    var content: AnyView {
        AnyView(VexillographerGroupContent(item: self))
    }

}

struct VexillographerGroupContent<Value: FlagContainer>: View {

    var item: VexillographerGroup<Value>

    @Environment(\.vexillographerContext) private var context

    var body: some View {
        if item.isHidden == false {
            switch item.group.displayOption {
            case .section:
                Section(item.name) {
                    ForEach(item.visibleItems, id: \.keyPath, content: \.content)
                }

            case .navigation, nil:
                NavigationLink(item.name) {
                    List {
                        if let description = item.group.description {
                            Section {
                                Text(description)
                            }
                        }
                        ForEach(item.visibleItems, id: \.keyPath, content: \.content)
                    }
                    .environment(\.vexillographerContext, context)
                }

            case .hidden:
                EmptyView()
            }
        }
    }

}
