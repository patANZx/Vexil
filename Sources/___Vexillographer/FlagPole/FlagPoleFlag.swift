struct FlagPoleFlag<Value: FlagValue>: FlagPoleItem {

    var wigwag: FlagWigwag<Value>

    var keyPath: FlagKeyPath { wigwag.keyPath }

}
