import SwiftUI

struct CaseIterableFlagControl: View {

    var configuration: CaseIterableFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol CaseIterableFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: CaseIterableFlagControlConfiguration where Value: CaseIterable & Hashable {

    func makeContent() -> any View {
        FlagPicker(configuration: self) {
            DefaultFlagPickerContent(Array(Value.allCases))
        }
    }

}
