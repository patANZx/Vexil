//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if !os(Linux)
import Combine
#endif

extension FlagValueDictionary: FlagValueSource {

    public func flagValue<Value>(key: String) -> Value? where Value: FlagValue {
        storage.withLock { storage in
            guard let value = storage[key] else {
                return nil
            }
            return Value(boxedFlagValue: value)
        }
    }

    public func setFlagValue(_ value: (some FlagValue)?, key: String) throws {
        _ = storage.withLock { storage in
            if let value {
                storage.updateValue(value.boxedFlagValue, forKey: key)
            } else {
                storage.removeValue(forKey: key)
            }
        }
        continuation.yield(key)
    }

    public func flagValueChanges(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) -> AsyncMapSequence<AsyncStream<String>, FlagChange> {
        stream.map {
            FlagChange.some([ keyPathMapper($0) ])
        }
    }

}
