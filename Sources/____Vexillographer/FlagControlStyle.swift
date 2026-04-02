import SwiftUI

public struct FlagControlStyleConfiguration<Value: FlagValue> {

    @Binding public var value: Value

}

/// Make custom styles
///
///
public protocol FlagControlStyle<Value>: DynamicProperty {

    associatedtype Value: FlagValue
    associatedtype Body: View

    typealias Configuration = FlagControlConfiguration

    @ViewBuilder @MainActor func makeBody(configuration: Configuration<Value>) -> Body

}

public extension View {

    func flagControlStyle<Style: FlagControlStyle>(_ style: Style) -> some View {
        environment(\.flagControlStyles[ObjectIdentifier(Style.Value.self)], style)
    }

    func flagControlStyle<Style: FlagControlStyle>(
        _ style: Style,
        for keyPath: KeyPath<some FlagContainer, Style.Value>
    ) -> some View {
        environment(\.flagControlStyles[keyPath], style)
    }

}

extension EnvironmentValues {

    @Entry var flagControlStyles = [AnyHashable: any FlagControlStyle]()

}
