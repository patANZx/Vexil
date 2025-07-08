//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import AsyncAlgorithms

/// An internal storage type that the FlagPole can use to keep track of sources and change streams.
///
/// This works by subscribing everything through a central `channel`:
///
///     Source 1───┐   ┌───────────┐  ┌──► Subscriber 1
///                │   │           │  │
///     Source 2───┼──►│  Stream   ├──┼──► Subscriber 2
///                │   │           │  │
///     Source 3───┘   └───────────┘  └──► Subscriber 3
///
struct StreamManager {

    // MARK: - Properties

    /// An array of `FlagValueSource`s that are used during flag value lookup.
    ///
    /// The order of this array is the order used when looking up flag values.
    ///
    var sources: [any FlagValueSource]

    /// This channel acts as our central "Subject" (in Combine terms). The channel is
    /// listens to change streams coming from the various sources, and subscribers to this
    /// FlagPole listen to changes from the channel.
    var stream: Stream?

    /// All of the active tasks that are iterating over changes emitted by the sources and sending them to the change stream
    var tasks = [(String, Task<Void, Never>)]()

}

// MARK: - Stream Setup: Subject -> Sources

extension FlagPole {

    var stream: StreamManager.Stream {
        manager.withLock { manager in
            // Streaming already started
            if let stream = manager.stream {
                return stream
            }

            // Setup streaming
            let stream = StreamManager.Stream(keyPathMapper: _configuration.makeKeyPathMapper())
            manager.stream = stream
            subscribeChannel(oldSources: [], newSources: manager.sources, on: &manager, isInitialSetup: true)
            return stream
        }
    }

    func subscribeChannel(oldSources: [any FlagValueSource], newSources: [any FlagValueSource], on manager: inout StreamManager, isInitialSetup: Bool = false) {
        let difference = newSources.difference(from: oldSources, by: { $0.flagValueSourceID == $1.flagValueSourceID })
        var didChange = false

        // If a source has been removed, cancel any streams using it
        if difference.removals.isEmpty == false {
            didChange = true
            for removal in difference.removals {
                manager.tasks.removeAll { task in
                    if task.0 == removal.element.flagValueSourceID {
                        task.1.cancel()
                        return true
                    } else {
                        return false
                    }
                }
            }
        }

        // Setup streaming for all new sources
        if difference.insertions.isEmpty == false {
            didChange = true
            for insertion in difference.insertions {
                manager.tasks.append(
                    (insertion.element.flagValueSourceID, makeSubscribeTask(for: insertion.element))
                )
            }
        }

        // If we have changed then the values returned by any flag could be
        // different know, so we let everyone know.
        if isInitialSetup == false, didChange {
            manager.stream?.send(.all)
        }
    }

    private func makeSubscribeTask(for source: some FlagValueSource) -> Task<Void, Never> {
        .detached { [manager, _configuration] in
            do {
                for try await change in source.flagValueChanges(keyPathMapper: _configuration.makeKeyPathMapper()) {
                    manager.withLock {
                        $0.stream?.send(change)
                    }
                }

            } catch {
                // the source's change stream threw; treat it as
                // if it finished (by doing nothing about it)
            }
        }
    }

}

extension StreamManager {

    /// A  convenience wrapper to AsyncStream.
    ///
    /// As this stream sits at the core of Vexil's observability stack it **must** support
    /// multiple producers (flag value sources) and multiple consumers (subscribers).
    /// Fortunately, AsyncStream supports multiple consumers out of the box (with one exception,
    /// see below). And it is fairly trivial for us to collect values from multiple producers into the
    /// AsyncStream.
    ///
    /// Unfortunately, there is one small bug with `AsyncStream` in that it does not
    /// propagate the `.finished` event to all of its consumers, only the first one:
    /// https://github.com/apple/swift/issues/66541
    ///
    /// Fortunately, we don't really support finishing the stream anyway unless the `FlagPole`
    /// is deinited, which doesn't happen often.
    ///
    struct Stream {

        let value: AsyncCurrentValue<FlagChange>
        var stream: AsyncStream<FlagChange> {
            let values = value.values
            var iterator = values.makeAsyncIterator()
            return AsyncStream {
                await iterator.next()
            }
        }
//        var continuation: AsyncStream<FlagChange>.Continuation
        let keyPathMapper: @Sendable (String) -> FlagKeyPath

        init(keyPathMapper: @Sendable @escaping (String) -> FlagKeyPath) {
            let (stream, continuation) = AsyncStream<FlagChange>.makeStream()
            self.value = AsyncCurrentValue(FlagChange.all)
//            self.stream = stream
//            self.continuation = continuation
            self.keyPathMapper = keyPathMapper
        }

        func finish() {
//            continuation.finish()
        }

        func send(_ change: FlagChange) {
            value.update { $0 = change }
//            continuation.yield(change)
        }

        func send(keys: Set<String>) {
            if keys.isEmpty {
                send(.all)
            } else {
                send(.some(Set(keys.map(keyPathMapper))))
            }
        }
    }

}

import Foundation

public struct AsyncCurrentValue<Wrapped: Sendable>: Sendable {

    struct State {
        // iterators start with generation = 0, so our initial value
        // has generation 1, so even that will be delivered.
        var generation = 1
        var wrappedValue: Wrapped {
            didSet {
                generation += 1
                for (_, continuation) in pendingContinuations {
                    continuation.resume(returning: (generation, wrappedValue))
                }
                pendingContinuations = []
            }
        }

        var pendingContinuations = [(UUID, CheckedContinuation<(Int, Wrapped)?, Never>)]()
    }

    final class Allocation: Sendable {
        let mutex: Mutex<State>

        init(state: sending State) {
            mutex = Mutex(state)
        }
    }

    // MARK: - Properties

    let allocation: Allocation

    // get-only; providing set would encourage `currentValue += 1`
    // which is a race (lock taken twice). Use
    // `$currentValue.update { $0 += 1 }` instead.

    /// Access to the current value.
    public var value: Wrapped {
        allocation.mutex.withLock { $0.wrappedValue }
    }

    // MARK: - Initialisation

    /// Creates a `CurrentValue` with an initial value
    public init(_ initialValue: sending Wrapped) {
        allocation = .init(state: State(wrappedValue: initialValue))
    }

    // MARK: - Mutation

    /// Updates the current state using the supplied closure.
    ///
    /// - Parameters:
    ///   - body:               A closure that passes the current value as an in-out parameter that you can mutate.
    ///                         When the closure returns the mutated value is saved as the current value and is sent to all subscribers.
    ///
    public func update<R: Sendable, E: Error>(_ body: (inout sending Wrapped) throws(E) -> R) throws(E) -> R {
        // have to use a local function to get a closure with a typed throw until the
        // FullTypedThrows feature works
        func lockBody(state: inout sending State) throws(E) -> sending R {
            var wrappedValue = state.wrappedValue
            do {
                let result = try body(&wrappedValue)
                state.wrappedValue = wrappedValue
                return result
            } catch {
                state.wrappedValue = wrappedValue
                throw error
            }
        }
        let result = try allocation.mutex.withLock(lockBody)
        // You should be able to replace `R: Sendable` above with `-> sending R`,
        // but the return statement below gives:
        //
        // Returning task-isolated 'result' risks causing data races since the
        // caller assumes that 'result' can safely be sent to other isolation
        // domains
        //
        // This is surely a compiler bug — `withLock` just returned
        // `result` as `sending`.
        return result
    }

    public struct Values: AsyncSequence {

        public typealias Element = Wrapped
        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        public typealias Failure = Never

        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(allocation: allocation)
        }

        weak var allocation: Allocation?

    }

    public var values: Values {
        Values(allocation: allocation)
    }

}

// MARK: - AsyncIterator

public extension AsyncCurrentValue.Values {

    struct AsyncIterator: AsyncIteratorProtocol {

        weak var allocation: AsyncCurrentValue.Allocation?
        var generation = 0

        public mutating func next() async -> Element? {
            // is `#isolation` or `nil` better here?
            await next(isolation: #isolation)
        }

        public mutating func next(isolation actor: isolated (any Actor)?) async -> Wrapped? {
            guard let allocation else {
                return nil
            }
            let uuid = UUID()
            let generationAndResult = await withTaskCancellationHandler {
                await withCheckedContinuation { (continuation: CheckedContinuation<(Int, Wrapped)?, Never>) in
                    allocation.mutex.withLock {
                        if Task.isCancelled {
                            // the iterating task is already cancelled, just return nil
                            continuation.resume(returning: nil)
                        } else if $0.generation > generation {
                            // the `CurrentValue` already has a newer value, just return it
                            continuation.resume(returning: ($0.generation, $0.wrappedValue))
                        } else {
                            // wait for the `CurrentValue` to be updated
                            $0.pendingContinuations.append((uuid, continuation))
                        }
                    }
                }
            } onCancel: {
                allocation.mutex.withLock {
                    if let index = $0.pendingContinuations.firstIndex(where: { $0.0 == uuid }) {
                        $0.pendingContinuations.remove(at: index).1.resume(returning: nil)
                    } else {
                        // onCancel: was called before operation:
                        // operation: will discover that Task.isCancelled
                    }
                }
            }
            guard let generationAndResult else {
                return nil
            }
            // ensure we don't return a duplicate value next time
            generation = generationAndResult.0
            return generationAndResult.1
        }
    }

}

// enum Backport {
//
// }
import Foundation

#if compiler(>=6)
/// A synchronization primitive that protects shared mutable state via mutual exclusion.
///
/// A back-port of Swift's `Mutex` type for wider platform availability.
#if hasFeature(StaticExclusiveOnly)
@_staticExclusiveOnly
#endif
package struct Mutex<Value: ~Copyable>: ~Copyable {
    private let _lock = NSLock()
    private let _box: Box

    /// Initializes a value of this mutex with the given initial state.
    ///
    /// - Parameter initialValue: The initial value to give to the mutex.
    package init(_ initialValue: consuming sending Value) {
        _box = Box(initialValue)
    }

    private final class Box {
        var value: Value
        init(_ initialValue: consuming sending Value) {
            value = initialValue
        }
    }
}

extension Mutex: @unchecked Sendable where Value: ~Copyable { }

package extension Mutex where Value: ~Copyable {
    /// Calls the given closure after acquiring the lock and then releases ownership.
    package borrowing func withLock<Result: ~Copyable, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result {
        _lock.lock()
        defer { _lock.unlock() }
        return try body(&_box.value)
    }

    /// Attempts to acquire the lock and then calls the given closure if successful.
    package borrowing func withLockIfAvailable<Result: ~Copyable, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result? {
        guard _lock.try() else { return nil }
        defer { _lock.unlock() }
        return try body(&_box.value)
    }
}
#else
package struct Mutex<Value> {
    private let _lock = NSLock()
    private let _box: Box

    package init(_ initialValue: consuming Value) {
        _box = Box(initialValue)
    }

    private final class Box {
        var value: Value
        init(_ initialValue: consuming Value) {
            value = initialValue
        }
    }
}

extension Mutex: @unchecked Sendable { }

package extension Mutex {
    package borrowing func withLock<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result {
        _lock.lock()
        defer { _lock.unlock() }
        return try body(&_box.value)
    }

    package borrowing func withLockIfAvailable<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result? {
        guard _lock.try() else { return nil }
        defer { _lock.unlock() }
        return try body(&_box.value)
    }
}
#endif

package extension Mutex where Value == Void {
    package borrowing func _unsafeLock() {
        _lock.lock()
    }

    package borrowing func _unsafeTryLock() -> Bool {
        _lock.try()
    }

    package borrowing func _unsafeUnlock() {
        _lock.unlock()
    }
}
