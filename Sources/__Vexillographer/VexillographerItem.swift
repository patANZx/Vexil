// Copyright © 2025 ANZ. All rights reserved.

import SwiftUI

protocol AnyVexillographerItem {

    var name: String { get }
    var keyPath: FlagKeyPath { get }
    var isHidden: Bool { get }
    @MainActor var content: AnyView { get }

}

struct VexillographerItem<Value: FlagValue>: AnyVexillographerItem {

    var flag: FlagWigwag<Value>

    init(_ flag: FlagWigwag<Value>) {
        self.flag = flag
    }

    var name: String { flag.name }
    var keyPath: FlagKeyPath { flag.keyPath }
    var isHidden: Bool { flag.displayOption == .hidden }

    var content: AnyView {
        AnyView(VexillographerItemContent(item: self))
    }

}

struct VexillographerItemContent<Value: FlagValue>: View {

    var item: VexillographerItem<Value>

    @State private var isShowingDetail = false
    @FocusState private var isFocused

    @Environment(\.vexillographerContext) private var context

    var body: some View {
        FlagControl(item.flag) { configuration in
            HStack(spacing: 0) {
                //                if let styledControl = flagPoleContext.styledControl(configuration: configuration) {
                //                    styledControl
                //                } else if configuration.isEditable {
                //                    DefaultFlagControl(configuration: configuration)
                //                } else {
                                    FlagValueRow(configuration.name, value: configuration.value)
                //                }
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
            //            .sheet(isPresented: $isShowingDetail) {
            //                NavigationView {
            //                    FlagDetailView(configuration: configuration)
            //                }
            //            }
        }
    }

}




struct RowContent<Content: View>: View {

    var label: String
    var content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    init(_ label: String, value: some Any) where Content == Text {
        self.label = label
        self.content = Text(String(describing: value))
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
            Spacer()
            content
                .foregroundStyle(.secondary)
        }
    }

}


struct FlagValueRow<Value>: View {

    private var label: String
    private var value: Value?

    init(_ label: String, value: Value?) {
        self.label = label
        self.value = value
    }

    var body: some View {
        RowContent(label) {
            // Clean this up
            if let value {
                if let value = value as? any OptionalProtocol {
                    if let wrapped = value.wrapped {
                        Text(String(describing: wrapped))
                    } else {
                        Text("nil")
                    }
                } else {
                    Text(String(describing: value))
                }
            } else {
                Text("not set")
                    .italic()
            }
        }
    }

}




protocol OptionalProtocol {
    associatedtype Wrapped
    var wrapped: Wrapped? { get set }
}

extension Optional: OptionalProtocol {
    var wrapped: Wrapped? {
        get { self }
        set { self = newValue }
    }
}
