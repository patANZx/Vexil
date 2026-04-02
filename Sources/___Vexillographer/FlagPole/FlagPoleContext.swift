import SwiftUI

protocol FlagPoleItem {

    var keyPath: FlagKeyPath { get }

}

struct FlagPoleContext {

    var items: [any FlagPoleItem]
    var editableSource: (any FlagValueSource)?
    var sources: [any FlagValueSource] = []

}

extension EnvironmentValues {

    @Entry var flagPoleContext: FlagPoleContext?

}

extension FlagPoleContext {

    init<RootGroup: FlagContainer>(flagPole: FlagPole<RootGroup>, editableSource: (any FlagValueSource)?) {
        let cache = FlagPoleCache()
        flagPole.walk(visitor: cache)
        items = cache.items
        self.editableSource = editableSource
        sources = flagPole._sources
    }

}

private final class FlagPoleCache: FlagVisitor {

    var items = [any FlagPoleItem]()
    var groupStack = [AnyFlagPoleGroup]()

    func beginGroup(keyPath: FlagKeyPath, wigwag: () -> FlagGroupWigwag<some FlagContainer>) {
        groupStack.append(FlagPoleGroup(wigwag: wigwag(), items: []))
    }

    func visitFlag<Value: FlagValue>(
        keyPath: FlagKeyPath,
        value: () -> Value?,
        defaultValue: Value,
        wigwag: () -> FlagWigwag<Value>
    ) {
        appendToGroupOrRoot(FlagPoleFlag(wigwag: wigwag()))
    }

    func endGroup(keyPath: FlagKeyPath) {
        appendToGroupOrRoot(groupStack.removeLast())
    }

    private func appendToGroupOrRoot(_ newItem: any FlagPoleItem) {
        if groupStack.last != nil {
            groupStack[groupStack.count - 1].items.append(newItem)
        } else {
            items.append(newItem)
        }
    }

}

private protocol AnyFlagPoleGroup: FlagPoleItem {
    var items: [any FlagPoleItem] { get set }
}

extension FlagPoleGroup: AnyFlagPoleGroup { }

extension View {

    func flagPole<RootGroup: FlagContainer>(
        _ flagPole: FlagPole<RootGroup>,
        editableSource: (any FlagValueSource)? = nil
    ) -> some View {
        modifier(FlagPoleModifier(flagPole: flagPole, editableSource: editableSource))
    }

}

private struct FlagPoleModifier<RootGroup: FlagContainer>: ViewModifier {

    var flagPole: FlagPole<RootGroup>
    var editableSource: (any FlagValueSource)?

    @State private var flagPoleContext: FlagPoleContext?

    func body(content: Content) -> some View {
        content
            .environment(\.flagPoleContext, flagPoleContext)
            .task { // can update if needed..
                guard flagPoleContext == nil else {
                    return
                }
                flagPoleContext = FlagPoleContext(flagPole: flagPole, editableSource: editableSource)
            }
    }

}
