import SwiftUI

struct FlagPicker<Value: FlagValue, SelectionValue: Hashable, Content: View>: View {

    private var name: String
    @Binding private var value: Value
    private var selection: WritableKeyPath<Value, SelectionValue>
    private var content: Content

    init(
        configuration: FlagControlConfiguration<Value>,
        selection: WritableKeyPath<Value, SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        name = configuration.name
        _value = configuration.$value
        self.selection = selection
        self.content = content()
    }

    var body: some View {
        Picker(name, selection: $value[dynamicMember: selection]) {
            content
        }
    }

}

extension FlagPicker where SelectionValue == Value {

    init(configuration: FlagControlConfiguration<Value>, @ViewBuilder content: () -> Content) {
        self.init(configuration: configuration, selection: \.self, content: content)
    }

}

struct DefaultFlagPickerContent<SelectionValue: Hashable>: View {

    private var options: [SelectionValue]

    init(_ options: [SelectionValue]) {
        self.options = options
    }

    var body: some View {
        ForEach(options, id: \.self) { option in
            if let optional = option as? any OptionalProtocol {
                if let wrapped = optional.wrapped {
                    Text(String(flagDisplayValue: wrapped))
                } else {
                    Section {
                        Text("None")
                    }
                }
            } else {
                Text(String(flagDisplayValue: option))
            }
        }
    }

}
