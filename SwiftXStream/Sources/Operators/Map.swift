//
//  Map.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
    
    public func map<U>(_ projection: @escaping (T) -> U) -> Stream<U> {
        let producer = Operators.Map(inStream: self, projection: projection)
        return Stream<U>(producer: producer)
    }
}

extension Operators {
    
    public class Map<T, U>: Listener, Producer {
        public typealias Output = U
        public typealias Input = T
        
        private let inStream: Stream<T>
        private var outStream: AnyListener<U>?
        private let projection: (T) -> U
        private var subscription: Subscription?
        
        init(inStream: Stream<T>, projection: @escaping (T) -> U) {
            self.inStream = inStream
            self.projection = projection
        }
        
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            outStream = AnyListener(listener)
            subscription = inStream.add(self)
        }
        
        public func stop() {
            subscription?.cancel()
            subscription = nil
            outStream = nil
        }
        
        public func next(_ value: T) {
            let projected = projection(value)
            outStream?.next(projected)
        }
        
        public func error(_ error: Error) {
            outStream?.error(error)
        }
        
        public func complete() {
            outStream?.complete()
        }
    }
}
