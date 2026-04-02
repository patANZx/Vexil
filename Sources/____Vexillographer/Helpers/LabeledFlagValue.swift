import SwiftUI

struct LabeledFlagValue<Value: FlagValue>: View {

    private var label: String
    private var value: Value?

    init(_ label: String, value: Value?) {
        self.label = label
        self.value = value
    }

    var body: some View {
        RowContent(label) {
            if let value {
                if let value = value as? any OptionalProtocol {
                    if let wrapped = value.wrapped {
                        Text(String(flagDisplayValue: wrapped))
                    } else {
                        Text("nil")
                    }
                } else {
                    Text(String(flagDisplayValue: value))
                }
            } else {
                Text("not set")
                    .italic()
            }
        }
    }

}
