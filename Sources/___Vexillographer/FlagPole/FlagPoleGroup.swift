struct FlagPoleGroup<Value: FlagContainer>: FlagPoleItem {

    var wigwag: FlagGroupWigwag<Value>
    var items: [any FlagPoleItem]

    var keyPath: FlagKeyPath { wigwag.keyPath }

}


protocol VexillographerContent {

}

struct VexillographerGroupContent
