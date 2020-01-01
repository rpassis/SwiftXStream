//
//  Listener.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/23/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

public protocol Listener {
    associatedtype Input
    func next(_ value: Input)
    func error(_ error: Error)
    func complete()
}

public struct AnyListener<T>: Listener {
    
    public typealias Input = T
    
    private let uuid = UUID()
    private let _next: (T) -> Void
    private let _error: (Error) -> Void
    private let _complete: () -> Void
    
    public init<L: Listener>(_ listener: L) where L.Input == Input {
        self._next = listener.next(_:)
        self._error = listener.error(_:)
        self._complete = listener.complete
    }
    
    public init(
        onNext: @escaping (Input) -> Void,
        onError: @escaping (Error) -> Void,
        onComplete: @escaping () -> Void
    ) {
        self._next = onNext
        self._error = onError
        self._complete = onComplete
    }
    
    public func next(_ value: Input) {
        self._next(value)
    }
    
    public func error(_ error: Error) {
        self._error(error)
    }
    
    public func complete() {
        self._complete()
    }
}

extension AnyListener: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
