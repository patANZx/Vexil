// Copyright © 2025 ANZ. All rights reserved.

import SwiftUI

protocol FlagItem {

    var name: String { get }
    var keyPath: FlagKeyPath { get }
    var isHidden: Bool { get }

}
