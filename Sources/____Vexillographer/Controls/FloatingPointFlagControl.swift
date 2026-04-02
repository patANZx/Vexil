import SwiftUI

struct FloatingPointFlagControl: View {

    var configuration: FloatingPointFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol FloatingPointFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: FloatingPointFlagControlConfiguration where Value.BoxedValueType: BinaryFloatingPoint {

    func makeContent() -> any View {
        FlagTextField(
            configuration: self,
            formatted: \.asString,
            editingFormat: { $0 }
        )
#if os(iOS) || os(tvOS)
        .keyboardType(.decimalPad)
#endif
    }

}

private extension FlagValue where BoxedValueType: BinaryFloatingPoint {

    var asString: String {
        get {
            Double(boxedFlagValue: boxedFlagValue)?.description ?? ""
        }
        set {
            let boxedFlagValue = newValue.isEmpty ? BoxedFlagValue.double(0) : .double(Double(newValue) ?? 0)
            self = Self(boxedFlagValue: boxedFlagValue) ?? self
        }
    }

}
