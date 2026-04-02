// Copyright © 2025 ANZ. All rights reserved.

import SwiftUI

struct FlagContext {

    var items = [any FlagItem]()
    var editableSource: (any FlagValueSource)?
    var sources: [any FlagValueSource] = []

}

extension EnvironmentValues {

    @Entry var flagContext = FlagContext()

}
