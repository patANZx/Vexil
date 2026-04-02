import SwiftUI
import Vexil

public extension View {

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

    @StateObject private var storage = FlagPoleContextStorage()

    func body(content: Content) -> some View {
        // TODO: Can cache this.
        let visitor = FlagPoleVisitor(lookup: flagPole)
        flagPole.walk(visitor: visitor)
        storage.context.items = visitor.items
        storage.context.keyPathByFlagKeyPath = visitor.keyPathByFlagKeyPath
        storage.context.editableSource = editableSource
        storage.context.sources = flagPole._sources
        return content
            .transformEnvironment(\.flagPoleContext) {
                $0.items = visitor.items
                $0.keyPathByFlagKeyPath = visitor.keyPathByFlagKeyPath
                $0.editableSource = editableSource
                $0.sources = flagPole._sources
            }
            .environmentObject(storage)
    }
}




final class FlagPoleContextStorage: ObservableObject {
    var context = FlagPoleContext()
}
