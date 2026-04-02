import SwiftUI

struct OptionalCaseIterableFlagControl: View {

    var configuration: OptionalCaseIterableFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol OptionalCaseIterableFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: OptionalCaseIterableFlagControlConfiguration where Value: OptionalProtocol, Value.Wrapped: CaseIterable & Hashable {
    func makeContent() -> any View {
        FlagPicker(configuration: self, selection: \.wrapped) {
            DefaultFlagPickerContent([nil as Value.Wrapped?] + Array(Value.Wrapped.allCases))
        }
    }
}
