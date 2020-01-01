//
//  Buffer.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/27/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
    public func buffer() -> Stream<[T]> {
        let producer = Operators.Buffer(inStream: self)
        return Stream<[T]>(producer: producer)
    }
}

extension Operators {
    
    public class Buffer<T>: Operator {
        
        public typealias Input = T
        public typealias Output = [T]
        
        private let inStream: Stream<Input>
        private var outStream: AnyListener<Output>?
        private var subscription: Subscription?
        private var buffer: Output = []
        
        init(inStream: Stream<Input>) {
            self.inStream = inStream
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
            buffer.append(value)
        }
        
        public func error(_ error: Error) {
            buffer = []
            outStream?.error(error)
        }
        
        public func complete() {
            if buffer.isEmpty == false {
                outStream?.next(buffer)
                buffer = []
            }
            outStream?.complete()
        }
    }
}
