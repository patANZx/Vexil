import SwiftUI

struct OptionalFloatingPointFlagControl: View {

    var configuration: OptionalFloatingPointFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol OptionalFloatingPointFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalFloatingPointFlagControlConfiguration where Value.BoxedValueType: OptionalProtocol, Value.BoxedValueType.Wrapped: BinaryFloatingPoint {

    func makeContent() -> any View {
        FlagTextField(
            configuration: self,
            formatted: \.asStringOrEmpty,
            editingFormat: { $0 }
        )
#if os(iOS) || os(tvOS)
        .keyboardType(.decimalPad)
#endif
    }

}

private extension FlagValue where BoxedValueType: OptionalProtocol, BoxedValueType.Wrapped: BinaryFloatingPoint {

    var asStringOrEmpty: String {
        get {
            Double(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.none : .double(Double(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }

}
