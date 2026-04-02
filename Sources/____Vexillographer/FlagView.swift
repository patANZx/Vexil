import SwiftUI

struct FlagView<Value: FlagValue, Content: View>: View {

    private var wigwag: FlagWigwag<Value>
    private var content: (FlagContext<Value>) -> Content

    @State private var cachedValue: Value?
    @State private var seed = 0

    @Environment(\.flagPoleContext) private var flagPoleContext

    init(
        _ wigwag: FlagWigwag<Value>,
        @ViewBuilder content: @escaping (FlagContext<Value>) -> Content
    ) {
        self.wigwag = wigwag
        self.content = content
    }

    var body: some View {
        content(
            FlagContext(
                name: wigwag.name,
                description: wigwag.description,
                keyPath: wigwag.keyPath,
                isEditable: isEditable,
                hasValue: editableSourceValue != nil,
                defaultValue: wigwag.defaultValue,
                value: value,
                resetValue: resetValue
            )
        )
        .task(id: wigwag.keyPath) {
            for await _ in wigwag.changes {
                cachedValue = resolvedValue
                seed += 1
            }
        }
    }

    private var isEditable: Bool {
        flagPoleContext.keyPathByFlagKeyPath[wigwag.keyPath] != nil && flagPoleContext.editableSource != nil
    }

    private var editableSourceValue: Value? {
        flagPoleContext.editableSource?.flagValue(key: wigwag.key)
    }

    private var nonEditableSourceValue: Value {
        let editableSourceID = flagPoleContext.editableSource?.flagValueSourceID
        for source in flagPoleContext.sources where source.flagValueSourceID != editableSourceID {
            if let value = source.flagValue(key: wigwag.key) as Value? {
                return value
            }
        }
        return wigwag.defaultValue
    }

    private var resolvedValue: Value {
        editableSourceValue ?? nonEditableSourceValue
    }

    private var value: Binding<Value> {
        Binding {
            cachedValue ?? resolvedValue
        } set: { newValue, transaction in
            guard let editableSource = flagPoleContext.editableSource else {
                print("Trying to set a value that isn't editable. This will be ignored.")
                return
            }
            do {
                $cachedValue.transaction(transaction).wrappedValue = newValue
                try editableSource.setFlagValue(newValue, key: wigwag.key)
            } catch {
                print("Error trying to set value.")
            }
        }
    }

    private func resetValue() {
        guard let editableSource = flagPoleContext.editableSource else {
            print("Trying to set a value that isn't editable. This will be ignored.")
            return
        }
        do {
            cachedValue = nonEditableSourceValue
            seed += 1
            try editableSource.setFlagValue(nil as Value?, key: wigwag.key)
        } catch {
            print("Error trying to reset value.")
        }
    }

}

struct FlagContext<Value: FlagValue> {

    let name: String
    let description: String?
    let keyPath: FlagKeyPath
    let isEditable: Bool
    let hasValue: Bool
    let defaultValue: Value
    @Binding public var value: Value

    private let _resetValue: () -> Void

    init(
        name: String,
        description: String?,
        keyPath: FlagKeyPath,
        isEditable: Bool,
        hasValue: Bool,
        defaultValue: Value,
        value: Binding<Value>,
        resetValue: @escaping () -> Void
    ) {
        self.name = name
        self.description = description
        self.keyPath = keyPath
        self.isEditable = isEditable
        self.hasValue = hasValue
        self.defaultValue = defaultValue
        _value = value
        _resetValue = resetValue
    }

    var key: String {
        keyPath.key
    }

    func resetValue() {
        _resetValue()
    }

}
