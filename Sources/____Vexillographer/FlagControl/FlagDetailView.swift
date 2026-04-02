import SwiftUI

struct FlagDetailView<Value: FlagValue>: View {

    var configuration: FlagControlConfiguration<Value>

    @Environment(\.dismiss) private var dismiss
    @Environment(\.flagPoleContext) private var flagPoleContext

    var body: some View {
        List {
            Section {
                if let description = configuration.description {
                    Text(description)
                }
                RowContent("Key", value: configuration.keyPath.key)
            }
            if let editableSource = flagPoleContext.editableSource {
                let editableValue = editableSource.flagValue(key: configuration.key) as Value?
                Section("Current Source") {
                    LabeledFlagValue(editableSource.flagValueSourceName, value: editableValue)
#if os(macOS)
                    RowContent("Clear Current Source") {
                        Button("Clear", role: .destructive) {
                            configuration.resetValue()
                        }
                        .disabled(editableValue == nil)
                    }
#else
                    Button("Clear Current Source", role: .destructive) {
                        configuration.resetValue()
                    }
                    .disabled(editableValue == nil)
#endif
                }
            }
            Section("Flagpole Source Hierarchy") {
                ForEach(flagPoleContext.sources, id: \.flagValueSourceID) { source in
                    let isEditableSource = source.flagValueSourceID == flagPoleContext.editableSource?.flagValueSourceID
                    let sourceValue = source.flagValue(key: configuration.key) as Value?
                    LabeledFlagValue(source.flagValueSourceName, value: sourceValue)
                        .font(isEditableSource ? .headline : nil)
                }
                LabeledFlagValue("Default Value", value: configuration.defaultValue)
            }
        }
        .navigationTitle(configuration.name)
#if os(macOS)
            .padding(0) // FIXME: Views for mac
#elseif !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
    }
}



