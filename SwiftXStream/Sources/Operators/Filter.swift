//
//  Filter.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
    public func filter(_ filter: @escaping (T) throws -> Bool) -> Stream<T> {
        let producer = Operators.Filter(inStream: self, filter: filter)
        return Stream(producer: producer)
    }
}

extension Operators {
        
    public class Filter<T>: Operator {
        public typealias Input = T
        public typealias Output = T
        
        private let inStream: Stream<T>
        private let filter: (T) throws -> Bool
        private var outStream: AnyListener<T>?
        private var subscription: Subscription?
        
        init(inStream: Stream<T>, filter: @escaping (T) throws -> Bool) {
            self.inStream = inStream
            self.filter = filter
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
        
        public func next(_ value: Output) {
            do {
                let shouldFilter = try self.filter(value)
                if shouldFilter == true {
                    outStream?.next(value)
                }
            } catch {
                // No-op
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
