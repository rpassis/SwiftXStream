//
//  Stream.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/23/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

public class Stream<T>: Listener {
    
    public typealias Input = T
    
    private let producer: AnyProducer<T>
    internal var listeners: Set<AnyListener<T>> = []
    
    deinit {
        print ("Stream for \(producer) gone")
    }
    
    public init<P: Producer>(producer: P) where P.Output == Input {
        self.producer = AnyProducer(producer)
    }

    public func next(_ value: Input) {
        listeners.forEach { $0.next(value) }
    }
    
    public func error(_ error: Error) {
        listeners.forEach { $0.error(error) }
        tearDown()
    }
    
    public func complete() {
        listeners.forEach { $0.complete() }
        tearDown()
    }
    
    private func tearDown() {
        producer.stop()
        listeners = []
    }

    public func add<L: Listener>(_ listener: L) -> Subscription where L.Input == Input {
        let anyListener = AnyListener(listener)
        return self.add(anyListener)
    }
    
    public func add(_ listener: AnyListener<Input>) -> Subscription {
        listeners.update(with: listener)
        if listeners.count == 1 {
            producer.start(listener: self)
        }
        return Subscription({ self.remove(listener) })
    }
    
    public func add(
        onNext: @escaping (T) -> Void,
        onError: @escaping (Error) -> Void,
        onComplete: @escaping () -> Void
    ) -> Subscription {
        let listener = AnyListener(onNext: onNext, onError: onError, onComplete: onComplete)
        return add(listener)
    }
    
    public func remove(_ listener: AnyListener<Input>) {
        listeners.remove(listener)
        if listeners.count == 0 {
            producer.stop()
        }
    }
}
