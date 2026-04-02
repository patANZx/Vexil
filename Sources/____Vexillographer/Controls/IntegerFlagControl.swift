import SwiftUI

struct IntegerFlagControl: View {

    var configuration: IntegerFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol IntegerFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: IntegerFlagControlConfiguration where Value.BoxedValueType: BinaryInteger {
    func makeContent() -> any View {
        FlagTextField(
            configuration: self,
            formatted: \.asString,
            editingFormat: { $0.filter(\.isNumber) }
        )
#if os(iOS) || os(tvOS)
        .keyboardType(.numberPad)
#endif
    }
}

private extension FlagValue where BoxedValueType: BinaryInteger {
    var asString: String {
        get {
            Int(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.integer(0) : .integer(Int(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }
}
