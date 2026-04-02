import SwiftUI

// TODO: Dev Docs
struct FlagPoleContext {

    var items = [any FlagPoleItem]()
    var editableSource: (any FlagValueSource)?
    var sources = [any FlagValueSource]()
    var keyPathByFlagKeyPath = [FlagKeyPath: AnyKeyPath]()
    var flagPoleID: ObjectIdentifier?

}

extension EnvironmentValues {

    @Entry var flagPoleContext = FlagPoleContext()

}

extension FlagPoleContext {

    mutating func update<RootGroup: FlagContainer>(flagPole: FlagPole<RootGroup>, editableSource: (any FlagValueSource)?) {
        // TODO: Dev Docs
        let flagPoleID = ObjectIdentifier(flagPole)
        let sources = flagPole._sources

        guard
            self.flagPoleID != flagPoleID
            || self.editableSource?.flagValueSourceID != editableSource?.flagValueSourceID
            || self.sources.map(\.flagValueSourceID) != sources.map(\.flagValueSourceID)
        else {
            // FIXME: This means the context will be the same right?
            return
        }

        // FIXME: Should probably check if editableSource is in sources
        self.editableSource = editableSource
        self.sources = sources
        self.flagPoleID = flagPoleID

        let cache = FlagPoleCache(lookup: flagPole)
        flagPole.walk(visitor: cache)

        items = cache.items
        keyPathByFlagKeyPath = cache.keyPathByFlagKeyPath
    }

}

private final class FlagPoleCache: FlagVisitor {

    let lookup: any FlagLookup

    var items = [any FlagPoleItem]()
    var groupStack = [FlagGroupCache]()
    var keyPathByFlagKeyPath = [FlagKeyPath: AnyKeyPath]()

    init(lookup: any FlagLookup) {
        self.lookup = lookup
    }

    func beginContainer(keyPath: FlagKeyPath, containerType: any Any.Type) {
        guard let containerType = containerType as? any FlagContainer.Type else {
            return
        }
        let container = containerType.init(_flagKeyPath: keyPath, _flagLookup: lookup)
        keyPathByFlagKeyPath.merge(container.keyPathByFlagKeyPath, uniquingKeysWith: { $1 })
    }

    func beginGroup(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<some FlagContainer>) {
        groupStack.append(FlagGroupCache(wigwag: wigwag()))
    }

    func visitFlag<Value: FlagValue>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) {
        appendToGroupOrRoot(FlagConfiguration(wigwag: wigwag()))
    }

    func endGroup(keyPath: FlagKeyPath) {
        let group = groupStack.removeLast().finalize()
        appendToGroupOrRoot(group)
    }

    private func appendToGroupOrRoot(_ newItem: any FlagPoleItem) {
        if let group = groupStack.last {
            group.append(newItem)
        } else {
            items.append(newItem)
        }
    }

}

private class FlagGroupCache {

    private var makeGroup: ([any FlagPoleItem]) -> any FlagPoleItem
    var items: [any FlagPoleItem] = []

    init(wigwag: FlagGroupWigwag<some FlagContainer>) {
        makeGroup = { FlagGroupConfiguration(wigwag: wigwag, items: $0) }
    }

    func append(_ newItem: any FlagPoleItem) {
        items.append(newItem)
    }

    func finalize() -> any FlagPoleItem {
        makeGroup(items)
    }

}

private extension FlagContainer {

    /// A map of type-erased key paths by flag key path.
    var keyPathByFlagKeyPath: [FlagKeyPath: AnyKeyPath] {
        Dictionary(uniqueKeysWithValues: _allFlagKeyPaths.map { ($0.value, $0.key) })
    }

}
