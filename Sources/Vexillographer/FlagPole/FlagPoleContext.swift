import SwiftUI

// TODO: Dev Docs
struct FlagPoleContext {

    var items = [any FlagPoleItem]()
    var editableSource: (any FlagValueSource)?
    var sources = [any FlagValueSource]()
    var keyPathByFlagKeyPath = [FlagKeyPath: AnyKeyPath]()
    var flagPoleID: ObjectIdentifier?

}
