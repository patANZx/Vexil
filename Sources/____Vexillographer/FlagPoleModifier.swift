import SwiftUI

extension View {

    // TODO: Docs
    func flagPole<RootGroup: FlagContainer>(
        _ flagPole: FlagPole<RootGroup>,
        editableSource: (any FlagValueSource)?
    ) -> some View {
        modifier(FlagPoleModifier(flagPole: flagPole, editableSource: editableSource))
    }

}

private struct FlagPoleModifier<RootGroup: FlagContainer>: ViewModifier {

    var flagPole: FlagPole<RootGroup>
    var editableSource: (any FlagValueSource)?

    @State private var flagPoleContext = FlagPoleContext()

    func body(content: Content) -> some View {
        content
            .environment(\.flagPoleContext, flagPoleContext)
            // FIXME: Should changes to flag pole and editableSource be observed?
            .task {
                flagPoleContext.update(flagPole: flagPole, editableSource: editableSource)
            }
    }

}
