//
//  Debug.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

public enum Event<T> {
    case next(T)
    case error(Error)
    case complete
}

extension Stream {
    public func debug(_ debug: @escaping @autoclosure () -> String) -> Stream<T> {
        let producer = Operators.Debug(debug(), self)
        return Stream(producer: producer)
    }
}

extension Operators {

    public class Debug<Value>: Operator {        
                      
        public typealias Output = Value
        public typealias Input = Value
        
        private let inStream: Stream<Value>
        private let debug: () -> String
        private var outStream: AnyListener<Value>?
        private var subscription: Subscription?
        
        public init(_ debug: @escaping @autoclosure () -> String, _ inStream: Stream<Value>) {
            self.inStream = inStream
            self.debug = debug
        }
        
        public func next(_ value: Input) {
            print("\(debug()): - onNext: \(value)")
            outStream?.next(value)
        }
        
        public func error(_ error: Error) {
            print("\(debug()): - onError: \(error)")
            outStream?.error(error)
        }
        
        public func complete() {
            print("\(debug()): - onComplete")
            outStream?.complete()
        }
                
        public func start<L>(listener: L) where L: Listener, Output == L.Input {
            self.outStream = AnyListener(listener)
            self.subscription = self.inStream.add(self)
        }
        
        public func stop() {
            subscription?.cancel()
            subscription = nil
            outStream = nil
        }
    }
}
