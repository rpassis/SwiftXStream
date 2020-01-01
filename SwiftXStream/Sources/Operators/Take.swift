//
//  Take.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
        
    public func take(_ total: Int) -> Stream<T> {
        let producer = Operators.Take(inStream: self, total: total)
        return Stream(producer: producer)
    }
}

extension Operators {
    
    public class Take<T>: Operator {
        
        public typealias Input = T
        public typealias Output = T
        
        private let total: Int
        private let inStream: Stream<T>
        private var outStream: AnyListener<T>?
        private var taken: Int = 0
        private var subscription: Subscription?
        
        init(inStream: Stream<T>, total: Int) {
            self.inStream = inStream
            self.total = total
        }
        
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            taken = 0
            outStream = AnyListener(listener)
            guard total > 0 else { complete(); return }
            subscription = inStream.add(self)
        }
        
        public func stop() {
            subscription?.cancel()
            subscription = nil
            outStream = nil
        }
        
        public func next(_ value: Input) {
            taken += 1
            if total < taken {
                // No-op
            } else if total == taken {
                outStream?.next(value)
                complete();
            } else {
                outStream?.next(value)
            }
        }
        
        public func error(_ error: Error) {
            outStream?.error(error)
        }
        
        public func complete() {
            outStream?.complete()
        }
    }
}
