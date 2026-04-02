import SwiftUI

struct OptionalIntegerFlagControl: View {

    var configuration: OptionalIntegerFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol OptionalIntegerFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalIntegerFlagControlConfiguration where Value.BoxedValueType: OptionalProtocol, Value.BoxedValueType.Wrapped: BinaryInteger {

    func makeContent() -> any View {
        FlagTextField(
            configuration: self,
            formatted: \.asStringOrEmpty,
            editingFormat: { $0.filter(\.isNumber) }
        )
#if os(iOS) || os(tvOS)
        .keyboardType(.numberPad)
#endif
    }

}

private extension FlagValue where BoxedValueType: OptionalProtocol, BoxedValueType.Wrapped: BinaryInteger {
    var asStringOrEmpty: String {
        get {
            Int(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.none : .integer(Int(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}
