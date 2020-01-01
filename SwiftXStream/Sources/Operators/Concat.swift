//
//  Concat.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/27/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
    
    public static func concat(_ streams: Stream<T>...) -> Stream<T> {
        let producer = Operators.Concat(inStreams: streams)
        return Stream(producer: producer)
    }
    
    public func concat(_ streams: Stream<T>...) -> Stream<T> {
        let producer = Operators.Concat(inStreams: [self] + streams)
        return Stream(producer: producer)
    }        
}

extension Operators {

    public class Concat<T>: Operator {
        
        public typealias Input = T
        public typealias Output = T
        
        private let inStreams: [Stream<T>]
        private var outStream: AnyListener<T>?
        private var subscription: Subscription?
        private var current: Int = 0
        
        init(inStreams: [Stream<T>]) {
            self.inStreams = inStreams
        }
            
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            current = 0
            outStream = AnyListener(listener)
            subscription = inStreams[current].add(self)
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
            outStream?.error(error)
        }
        
        public func complete() {
            subscription?.cancel()
            current += 1
            if current < inStreams.count {
                subscription = inStreams[current].add(self)
            } else {
                outStream?.complete()
            }
        }
    }
}
