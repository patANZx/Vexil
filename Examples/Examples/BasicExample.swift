// Copyright © 2025 ANZ. All rights reserved.

import SwiftUI
import Vexillographer

struct BasicExample: View {

    var body: some View {
        Vexillographer(flagPole: Self.flagPole, editableSource: .basicSource)
    }

    private static let flagPole = FlagPole(hoist: BuiltinTypes.self, sources: [.basicSource])

}

private extension FlagValueSource where Self == FlagValueSourceCoordinator<UserDefaults> {

    static var basicSource: Self { Self(source: UserDefaults(suiteName: "com.example.basic")!) }

}

@FlagContainer
private struct BuiltinTypes {

    @Flag("A boolean flag")
    var boolean = true

    @Flag("An optional boolean flag")
    var optionalBoolean: Bool?

    @Flag("A string flag")
    var string = "Blob"

    @Flag("An optional string flag")
    var optionalString: String?

    @Flag("An integer flag")
    var integer = 42

    @Flag("An optional integer flag")
    var optionalInteger: Int?

    @Flag("A double flag")
    var double = 1729.42

    @Flag("An optional double flag")
    var optionalDouble: Double?

    @Flag("An case iterable flag")
    var caseIterable = Enum.foo

    @Flag("An optional case iterable flag")
    var optionalCaseIterable: Enum?

    enum Enum: String, CaseIterable, FlagValue {
        case foo
        case bar
        case baz
    }

//    @FlagGroup("Navigation")
//    var navigation: NestedTypes
//
//    @FlagGroup(description: "Section", display: .section)
//    var section: NestedTypes
}

@FlagContainer
private struct NestedTypes {

    @Flag("A boolean flag")
    var boolean = true

    @Flag("An optional boolean flag")
    var optionalBoolean: Bool?

}

#Preview {
    BasicExample()
}
