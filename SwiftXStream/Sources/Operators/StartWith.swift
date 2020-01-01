//
//  StartWith.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {    
    public func startWith(_ value: T) -> Stream<T> {
        let producer = Producers.StartWith(inStream: self, initialValue: value)
        return Stream(producer: producer)
    }
}

extension Producers {
    public class StartWith<T>: Producer {
        
        public typealias Output = T
        private let initialValue: T
        private let inStream: Stream<T>
        private var subscription: Subscription?
        
        init(inStream: Stream<T>, initialValue: T) {
            self.initialValue = initialValue
            self.inStream = inStream
        }
        
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            listener.next(initialValue)
            subscription = inStream.add(listener)
        }
        
        public func stop() {
            subscription?.cancel()
            subscription = nil
        }
    }
}
