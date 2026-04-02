import SwiftUI

struct OptionalStringFlagControl: View {
    var configuration: OptionalStringFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }
}

protocol OptionalStringFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalStringFlagControlConfiguration where Value.BoxedValueType == String? {
    func makeContent() -> any View {
        FlagTextField(configuration: self, formatted: \.asStringOrEmpty, placeholder: "nil")
    }
}

private extension FlagValue where BoxedValueType == String? {
    var asStringOrEmpty: String {
        get {
            String(boxedFlagValue: boxedFlagValue) ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.none : .string(newValue)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}
