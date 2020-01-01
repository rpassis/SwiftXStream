//
//  Operator.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/23/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation
import Combine

public enum Producers { }
    
extension Producers {
    
    public struct Sequence<Element>: Producer {
            
        public typealias Output = Element
        
        private let sequence: AnySequence<Element>
        
        public init<S>(from sequence: S) where S: Swift.Sequence, S.Element == Element {
            self.sequence = AnySequence(sequence)
        }
        
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            sequence.forEach { listener.next($0) }
            listener.complete()
        }
        
        public func stop() {
            // No-op
        }
    }
    
    public class Future<Value>: Producer {
        
        public typealias Output = Result<Value, Never>
        
        private var result: ((AnyListener<Output>) -> Void)?
        private let queue = DispatchQueue(label: "com.xstream.future")
        private var deferredListeners: Set<AnyListener<Output>> = []
        
        public init(_ attemptoFulfill: @escaping (@escaping (Output) -> Void) -> Void) {
            attemptoFulfill { result in
                self.result = { listener in
                    listener.next(result)
                    listener.complete()
                }
                self.queue.async {
                    self.deferredListeners.forEach { self.result?($0) }
                    self.deferredListeners = []
                }
            }
        }
        
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            queue.async {
                guard let result = self.result else {
                    self.deferredListeners.update(with: AnyListener(listener))
                    return
                }
                result(AnyListener(listener))
            }
        }
        
        public func stop() {
            queue.async {
                self.result = nil
                self.deferredListeners = []
            }
        }
    }
    
    public class Periodic: Producer {
        
        public typealias Output = Int
        
        private let period: TimeInterval
        private var value: Int = 0
        private var timer: Timer?
        
        public init(period: TimeInterval) {
            self.period = period
        }
        
        public func start<L>(listener: L) where L : Listener, Output == L.Input {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: period, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.value += 1
                listener.next(self.value)
            }
        }
        
        public func stop() {
            timer?.invalidate()
        }
    }        
}
