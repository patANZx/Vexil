import SwiftUI

struct DefaultFlagControl<Value: FlagValue>: View {

    var configuration: FlagControlConfiguration<Value>

    var body: some View {
        switch configuration {
        case _ where configuration.isEditable == false:
            LabeledFlagValue(configuration.name, value: configuration.value)
        case let configuration as BooleanFlagControlConfiguration:
            BooleanFlagControl(configuration: configuration)
        case let configuration as OptionalBooleanFlagControlConfiguration:
            OptionalBooleanFlagControl(configuration: configuration)
        case let configuration as CaseIterableFlagControlConfiguration:
            CaseIterableFlagControl(configuration: configuration)
        case let configuration as OptionalCaseIterableFlagControlConfiguration:
            OptionalCaseIterableFlagControl(configuration: configuration)
        case let configuration as IntegerFlagControlConfiguration:
            IntegerFlagControl(configuration: configuration)
        case let configuration as OptionalIntegerFlagControlConfiguration:
            OptionalIntegerFlagControl(configuration: configuration)
        case let configuration as FloatingPointFlagControlConfiguration:
            FloatingPointFlagControl(configuration: configuration)
        case let configuration as OptionalFloatingPointFlagControlConfiguration:
            OptionalFloatingPointFlagControl(configuration: configuration)
        case let configuration as StringFlagControlConfiguration:
            StringFlagControl(configuration: configuration)
        case let configuration as OptionalStringFlagControlConfiguration:
            OptionalStringFlagControl(configuration: configuration)
        default:
            Text("Unimplemented \(configuration.name)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

}
