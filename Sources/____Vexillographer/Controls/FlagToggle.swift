import SwiftUI

/// A flag control that toggles between on and off states.
struct FlagToggle<Value: FlagValue>: View where Value.BoxedValueType == Bool {

    private var name: String
    @Binding private var value: Value

    init(configuration: FlagControlConfiguration<Value>) {
        name = configuration.name
        _value = configuration.$value
    }

    var body: some View {
        Toggle(name, isOn: $value.asBool)
    }

}

// MARK: - Private

private extension FlagValue where BoxedValueType == Bool {

    var asBool: Bool {
        get {
            Bool(boxedFlagValue: boxedFlagValue) ?? false
        }
        set {
            self = Self(boxedFlagValue: .bool(newValue)) ?? self
        }
    }

}
