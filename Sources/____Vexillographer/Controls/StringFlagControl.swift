import SwiftUI

struct StringFlagControl: View {

    var configuration: StringFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol StringFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: StringFlagControlConfiguration where Value.BoxedValueType == String {

    func makeContent() -> any View {
        FlagTextField(configuration: self, formatted: \.asString)
    }

}

private extension FlagValue where BoxedValueType == String {
    var asString: String {
        get {
            String(boxedFlagValue: boxedFlagValue) ?? ""
        }
        set {
            self = Self(boxedFlagValue: .string(newValue)) ?? self
        }
    }
}
