// Copyright © 2025 ANZ. All rights reserved.

struct FlagPoleContext {

    var items = [any FlagPoleItem]()
    var editableSource: (any FlagValueSource)?
    var sources: [any FlagValueSource] = []

}

private final class Cache: FlagVisitor {

    var items = [any FlagPoleItem]()
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
