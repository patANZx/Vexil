// Copyright © 2025 ANZ. All rights reserved.

import SwiftUI

protocol FlagPoleItem {

    var name: String { get }
    var keyPath: FlagKeyPath { get }
    var isVisible: Bool { get }
    var children: [any FlagPoleItem]? { get }
    @MainActor func makeContent() -> any View

}

struct FlagPoleItemContent: View {

    var item: any FlagPoleItem

    var body: some View {
        AnyView(item.makeContent())
    }

}
