//
//  Stream+Extensions.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/23/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

extension Stream {
    
    public static func never() -> Stream<T> {
        let p = AnyProducer<T>(start: { _ in }, stop: { })
        return Stream(producer: p)
    }
    
    public static func empty() -> Stream<T> {
        let p = AnyProducer<T>(start: { listener in listener.complete() }, stop: { })
        return Stream(producer: p)
    }
    
    public static func error(_ error: Error) -> Stream<T> {
        let p = AnyProducer<T>(start: { listener in listener.error(error) }, stop: { })
        return Stream(producer: p)
    }
    
    public static func from<S: Sequence>(_ sequence: S) -> Stream<T> where S.Element == T {
        let p = AnyProducer<T>(
            start: { listener in
                for element in sequence {
                    listener.next(element)
                }
                listener.complete()
            }, stop: {
                /* No-op */
            }
        )
        return Stream(producer: p)
    }    
}
