import SwiftUI

public struct FlagControl<Value: FlagValue, Content: View>: View {

    private var wigwag: FlagWigwag<Value>
    private var content: (FlagControlConfiguration<Value>) -> Content

//    @State private var cachedValue: Value?
//    @State private var seed = 0
    @State private var state = FlagState()

    struct FlagState {
        var value: Value? {
            didSet { seed += 1 }
        }
        var seed = 0
    }

    @Environment(\.flagPoleContext) private var flagPoleContext

    public init(
        _ wigwag: FlagWigwag<Value>,
        @ViewBuilder content: @escaping (FlagControlConfiguration<Value>) -> Content
    ) {
        self.wigwag = wigwag
        self.content = content
    }

    public var body: some View {
        content(
            FlagControlConfiguration(
                seed: 0,
                name: wigwag.name,
                description: wigwag.description,
                keyPath: wigwag.keyPath,
                isEditable: flagPoleContext.editableSource != nil,
                hasValue: editableValue != nil,
                defaultValue: wigwag.defaultValue,
                value: Binding(get:  { getValue() }, set: { setValue($0, transaction: $1) }),
                resetValue: { resetValue() }
            )
        )
        .task {
            for await _ in wigwag.changes {
//                seed += 1
                state.value = resolvedValue
            }
        }
    }

    private var editableValue: Value? {
        flagPoleContext.editableSource?.flagValue(key: wigwag.key)
    }

    private var nonEditableValue: Value {
        let editableSourceID = flagPoleContext.editableSource?.flagValueSourceID
        for source in flagPoleContext.sources where source.flagValueSourceID != editableSourceID {
            if let value = source.flagValue(key: wigwag.key) as Value? {
                return value
            }
        }
        return wigwag.defaultValue
    }

    private var resolvedValue: Value {
        editableValue ?? nonEditableValue
    }

    private func getValue() -> Value {
        state.value ?? resolvedValue
    }

    private func setValue(_ newValue: Value, transaction: Transaction) {
        // TODO: logging
        guard let editableSource = flagPoleContext.editableSource else {
            print("Trying to set a value that isn't editable. This will be ignored.")
            return
        }

        do {
            $state.value.transaction(transaction).wrappedValue = newValue
            try editableSource.setFlagValue(newValue, key: wigwag.key)
        } catch {
            print("Error trying to set value.")
        }
    }

    private func resetValue() {
        guard let editableSource = flagPoleContext.editableSource else {
            print("Trying to set a value that isn't editable. This will be ignored.")
            return
        }

        do {
//            seed += 1
            state.value = nonEditableValue
            try editableSource.setFlagValue(nil as Value?, key: wigwag.key)
        } catch {
            print("Error trying to reset value.")
        }
    }

}

public extension FlagControl where Content == DefaultFlagControlContent<Value> {

    /// Use the default control with custom styling
    ///
    ///
    init(_ wigwag: FlagWigwag<Value>) {
        self.init(wigwag, content: DefaultFlagControlContent.init)
    }

}

public struct DefaultFlagControlContent<Value: FlagValue>: View {

    var configuration: FlagControlConfiguration<Value>

    @State private var isShowingDetail = false
    @FocusState private var isFocused

    @Environment(\.flagPoleContext) private var flagPoleContext
    @Environment(\.flagControlStyles) private var flagControlStyles

    public var body: some View {
        HStack(spacing: 0) {
            if let styledFlagControl {
                styledFlagControl
            } else {
                DefaultFlagControl(configuration: configuration)
            }
            Spacer()
            Button {
                isFocused = false
                isShowingDetail = true
            } label: {
                Label("Info", systemImage: "info.circle")
                    .imageScale(.large)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.tint)
                    .symbolVariant(configuration.hasValue ? .fill : .none)
            }
            .buttonStyle(.plain)
        }
        .focused($isFocused)
#if !os(tvOS)
            .swipeActions(edge: .trailing) {
                if configuration.hasValue {
                    Button {
                        configuration.resetValue()
                    } label: {
                        Label("Clear", systemImage: "trash.fill")
                            .imageScale(.large)
                    }
                    .tint(.red)
                }
            }
#endif
            .sheet(isPresented: $isShowingDetail) {
                NavigationView {
                    FlagDetailView(configuration: configuration)
                }
            }
    }

    private var styledFlagControl: StyledFlagControl<Value>? {
        if let keyPath = flagPoleContext.keyPathByFlagKeyPath[configuration.keyPath], let style = flagControlStyles[keyPath] {
            style.makeView(configuration: configuration) as? StyledFlagControl<Value>
        } else if let style = flagControlStyles[ObjectIdentifier(Value.self)] {
            style.makeView(configuration: configuration) as? StyledFlagControl<Value>
        } else {
            nil
        }
    }

}

private extension FlagControlStyle {

    @MainActor
    func makeView(configuration: Any) -> some View {
        (configuration as? Configuration)
            .map { StyledFlagControl(configuration: $0, style: self) }
    }

}

private struct StyledFlagControl<Value: FlagValue>: View {

    var configuration: FlagControlConfiguration<Value>
    var style: any FlagControlStyle<Value>

    var body: some View {
        AnyView(style.makeBody(configuration: configuration))
    }

}
