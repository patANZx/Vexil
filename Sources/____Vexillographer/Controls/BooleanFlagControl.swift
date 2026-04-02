import SwiftUI

struct BooleanFlagControl: View {

    var configuration: BooleanFlagControlConfiguration

    var body: some View {
        AnyView(configuration.makeContent())
    }

}

protocol BooleanFlagControlConfiguration {
    @MainActor
    func makeContent() -> any View
}

extension FlagControlConfiguration: BooleanFlagControlConfiguration where Value.BoxedValueType == Bool {

    func makeContent() -> any View {
        FlagToggle(configuration: self)
    }

}
