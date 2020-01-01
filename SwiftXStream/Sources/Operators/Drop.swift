//
//  Drop.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
        
    public func dropFirst(max: Int = 1) -> Stream<T> {
        let producer = Operators.Drop(max: max, inStream: self)
        return Stream(producer: producer)
    }
}

extension Operators {
    
    public class Drop<T>: Operator {
        
        public typealias Input = T
        public typealias Output = T
        
        private let max: Int
        private let inStream: Stream<T>
        private var outStream: AnyListener<T>?
        private var droppedCount: Int = 0
        private var subscription: Subscription?
        
        init(max: Int, inStream: Stream<T>) {
            self.inStream = inStream
            self.max = max
        }
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            droppedCount = 0
            outStream = AnyListener(listener)
            subscription = inStream.add(self)
        }
        
        public func stop() {
            subscription?.cancel()
            subscription = nil
            outStream = nil
        }
        
        public func next(_ value: Operators.Drop<T>.Input) {
            droppedCount += 1
            guard droppedCount > max else { return }
            outStream?.next(value)
        }
        
        public func error(_ error: Error) {
            outStream?.error(error)
        }
        
        public func complete() {
            outStream?.complete()
        }
    }
}
