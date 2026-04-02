// Copyright © 2025 ANZ. All rights reserved.

import SwiftUI

struct FlagControlConfiguration<Value: FlagValue> {

    let name: String
    let description: String?
    let keyPath: FlagKeyPath
    let isEditable: Bool
    let hasValue: Bool
    let defaultValue: Value
    @Binding var value: Value

    private let _resetValue: () -> Void
    private let seed: Int

    init(
        seed: Int,
        name: String,
        description: String? = nil,
        keyPath: FlagKeyPath,
        isEditable: Bool,
        hasValue: Bool,
        defaultValue: Value,
        value: Binding<Value>,
        resetValue: @escaping () -> Void
    ) {
        self.seed = seed
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

struct FlagControl<Value: FlagValue, Content: View>: View {

    private var wigwag: FlagWigwag<Value>
    private var content: (FlagControlConfiguration<Value>) -> Content

    @State private var cachedValue: Value?
    @State private var seed = 0

    @Environment(\.vexillographerContext) private var context

    init(
        _ wigwag: FlagWigwag<Value>,
        @ViewBuilder content: @escaping (FlagControlConfiguration<Value>) -> Content
    ) {
        self.wigwag = wigwag
        self.content = content
    }

    var body: some View {
        content(
            FlagControlConfiguration(
                seed: seed,
                name: wigwag.name,
                description: wigwag.description,
                keyPath: wigwag.keyPath,
                isEditable: context.editableSource != nil,
                hasValue: editableValue != nil,
                defaultValue: wigwag.defaultValue,
                value: Binding(get: getValue, set: setValue),
                resetValue: resetValue
            )
        )
        .task {
            for await _ in wigwag.changes {
                seed += 1
                cachedValue = resolvedValue
            }
        }
    }

    private var editableValue: Value? {
        context.editableSource?.flagValue(key: wigwag.key)
    }

    private var nonEditableValue: Value {
        let editableSourceID = context.editableSource?.flagValueSourceID
        for source in context.sources where source.flagValueSourceID != editableSourceID {
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
        cachedValue ?? resolvedValue
    }

    private func setValue(_ newValue: Value, transaction: Transaction) {
        // TODO: logging
        guard let editableSource = context.editableSource else {
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

    private func resetValue() {
        guard let editableSource = context.editableSource else {
            print("Trying to set a value that isn't editable. This will be ignored.")
            return
        }

        do {
            seed += 1
            cachedValue = nonEditableValue
            try editableSource.setFlagValue(nil as Value?, key: wigwag.key)
        } catch {
            print("Error trying to reset value.")
        }
    }

}
