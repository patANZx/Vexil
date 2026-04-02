import SwiftUI

struct VexillographerContext {

    var items = [any AnyVexillographerItem]()
    var editableSource: (any FlagValueSource)?
    var sources: [any FlagValueSource] = []

}

extension EnvironmentValues {

    @Entry var vexillographerContext = VexillographerContext()

}

extension VexillographerContext {

    init<RootGroup: FlagContainer>(flagPole: FlagPole<RootGroup>, editableSource: (any FlagValueSource)?) {
        let cache = Cache()
        flagPole.walk(visitor: cache)
        items = cache.items
        self.editableSource = editableSource
        sources = flagPole._sources
    }

    private final class Cache: FlagVisitor {

        var items = [any AnyVexillographerItem]()
        var groupStack = [any AnyVexillographerGroup]()

        func beginGroup(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<some FlagContainer>) {
            groupStack.append(VexillographerGroup(wigwag()))
        }

        func visitFlag<Value: FlagValue>(
            keyPath: FlagKeyPath,
            value: () -> Value?,
            defaultValue: Value,
            wigwag: () -> FlagWigwag<Value>
        ) {
            appendToGroupOrRoot(VexillographerItem(wigwag()))
        }

        func endGroup(keyPath: FlagKeyPath) {
            appendToGroupOrRoot(groupStack.removeLast())
        }

        private func appendToGroupOrRoot(_ newItem: any AnyVexillographerItem) {
            if groupStack.last != nil {
                groupStack[groupStack.count - 1].items.append(newItem)
            } else {
                items.append(newItem)
            }
        }

    }

}
