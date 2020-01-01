//
//  ReplaceError.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
    
    public func onErrorReplace(with stream: Stream<T>) -> Stream<T> {
        let producer = Operators.ReplaceOnError(inStream: self) { _ in return stream }
        return Stream(producer: producer)
    }
}

extension Operators {
    
    public class ReplaceOnError<T>: Listener, Producer {
        
        public typealias Input = T
        public typealias Output = T
        
        private var inStream: Stream<T>
        private let onErrorReplace: (Error) -> Stream<T>
        private var outStream: AnyListener<T>?
        private var subscription: Subscription?
        
        init(inStream: Stream<T>, onErrorReplace: @escaping (Error) -> Stream<T>) {
            self.inStream = inStream
            self.onErrorReplace = onErrorReplace
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
            outStream?.next(value)
        }
        
        public func error(_ error: Error) {
            subscription?.cancel()
            inStream = onErrorReplace(error)
            subscription = inStream.add(self)
        }
        
        public func complete() {
            outStream?.complete()
        }
    }
}
