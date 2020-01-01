//
//  ViewController.swift
//  SwiftXStream-Example
//
//  Created by Rogerio Assis on 12/26/19.
//  Copyright © 2019 RDPA. All rights reserved.
//

import UIKit
import SwiftXStream

enum MyError: Error {
    case unknown
}

class ViewController: UIViewController {

    private var subscription: Subscription?
    private var listener: AnyListener<Int>?
    private var stream: SwiftXStream.Stream<Int>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stream1 = SwiftXStream.Stream<Int>.from([1,2,3,4])
        let stream2 = SwiftXStream.Stream<Int>.from([5,6])
        let stream3 = SwiftXStream.Stream<Int>.from([7,8,9])
        self.subscription = stream1
            .concat(stream2, stream3)            
            .map { "\($0) stringified" }
            .startWith("First!")
            .add(onNext: {
                print("Rog \($0)")
            }, onError: {
                print("Rog error: \($0)")
            }, onComplete: {
                print("Rog complete")
            })
    }
}

