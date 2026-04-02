extension String {

    init(flagDisplayValue: Any) {
        if let flagDisplayValue = (flagDisplayValue as? any FlagDisplayValue)?.flagDisplayValue {
            self = flagDisplayValue
        } else {
            self.init(describing: flagDisplayValue)
        }
    }

}
