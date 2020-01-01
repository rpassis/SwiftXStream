//
//  Producer.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/23/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

public protocol Producer {
    associatedtype Output
    func start<L: Listener>(listener: L) where L.Input == Output
    func stop()
}

public extension Producer {
    func eraseToAnyProducer() -> AnyProducer<Output> {
        return AnyProducer(self)
    }
}

public struct AnyProducer<T>: Producer {
    
    public typealias Output = T
    
    private let _start: (AnyListener<T>) -> Void
    private let _stop: () -> Void
    
    public init<P: Producer>(_ producer: P) where P.Output == Output {
        self.init(start: producer.start(listener:), stop: producer.stop)
    }
    
    public init(start: @escaping (AnyListener<Output>) -> Void, stop: @escaping () -> Void) {
        self._start = start
        self._stop = stop
    }
    
    public func start<L: Listener>(listener: L) where L.Input == Output {
        self._start(AnyListener(listener))
    }
    
    public func stop() {
        self._stop()
    }
}

