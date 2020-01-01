//
//  Subscription.swift
//  SwiftXStream
//
//  Created by Rogerio Assis on 12/23/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import Foundation

public class Subscription: Hashable {
    
    private lazy var identifier = ObjectIdentifier(self)
    
    public let cancellable: () -> Void
    private var isCancelled = false
    
    deinit {
        guard isCancelled == false else { return }
        cancellable()
    }
    
    public init (_ cancellable: @escaping () -> Void) {
        self.cancellable = cancellable
    }
    
    public func cancel() {
        guard isCancelled == false else { return }
        cancellable()
    }
    
    public static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
