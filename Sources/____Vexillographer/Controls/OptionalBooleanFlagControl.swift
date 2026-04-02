import SwiftUI

struct OptionalBooleanFlagControl: View {

    var configuration: OptionalBooleanFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol OptionalBooleanFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalBooleanFlagControlConfiguration where Value.BoxedValueType == Bool? {
    func makeContent() -> any View {
        FlagPicker(configuration: self, selection: \.asOptionalBool) {
            DefaultFlagPickerContent<Bool?>(Array([nil, true, false]))
        }
    }
}

private extension FlagValue where BoxedValueType == Bool? {

    var asOptionalBool: Bool? {
        get {
            Bool(boxedFlagValue: boxedFlagValue)
        }
        set {
            let boxedFlagValue = newValue.map(BoxedFlagValue.bool) ?? .none
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }

}
