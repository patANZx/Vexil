import SwiftUI

public struct Vexillographer<RootGroup: FlagContainer>: View {

    private var flagPole: FlagPole<RootGroup>
    private var source: (any FlagValueSource)?

    public init(flagPole: FlagPole<RootGroup>, source: (any FlagValueSource)?) {
        self.flagPole = flagPole
        self.source = source
    }

    public var body: some View {
        List {

        }
    }

}
