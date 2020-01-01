//
//  MemoryStream.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/27/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

public class MemoryStream<T>: Stream<T> {
    
    private var _value: T?
    
    override public func next(_ value: T) {
        self._value = value
        super.next(value)
    }

    override public func add(_ listener: AnyListener<Input>) -> Subscription {
        listeners.update(with: listener)
        if listeners.count > 1 {
            if let value = _value {
                listener.next(value)
            }
            return Subscription({ self.remove(listener) })
        }
        
        return super.add(listener)
    }
}
