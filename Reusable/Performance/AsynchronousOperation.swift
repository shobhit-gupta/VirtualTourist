//
//  AsynchronousOperation.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 06/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

// References:
// https://developer.apple.com/documentation/foundation/operation
// http://lorenzoboaro.io/2016/01/05/having-fun-with-operation-in-ios.html
// https://gist.github.com/calebd/93fa347397cec5f88233
// http://swiftgazelle.com/2016/03/asynchronous-nsoperation-why-and-how/


import Foundation


open class AsynchronousOperation: Operation {
    
    // MARK: Public variables and types
    public final override var isAsynchronous: Bool {
        return true
    }
    
    public final override var isExecuting: Bool {
        return state == .executing
    }
    
    public final override var isFinished: Bool {
        return state == .finished
    }
    
    public final override var isReady: Bool {
        // This should take care of dependencies
        return state == .ready && super.isReady
    }
    
    
    // MARK: Private variables and types
    @objc private enum State: Int {
        case ready
        case executing
        case finished
    }
    
    private let stateQueue = DispatchQueue(label: Default.DispatchQueue_.Label.AsynchronousOperation, attributes: .concurrent)
    
    private var _state = State.ready
    
    @objc private dynamic var state: State {
        get {
            return stateQueue.sync(execute: { _state })
        }
        set {
            willChangeValue(forKey: Default.AsynchronousOperation.KeyPath.State)
            stateQueue.sync(flags: .barrier, execute: { _state = newValue })
            didChangeValue(forKey: Default.AsynchronousOperation.KeyPath.State)
        }
    }
    
    
    // MARK: KVO
    // Tell KVO that any change to state variable is implicitly a change to isReady, isExecuting and isFinished
    @objc private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return [Default.AsynchronousOperation.KeyPath.State]
    }
    
    
    @objc private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return [Default.AsynchronousOperation.KeyPath.State]
    }
    
    
    @objc private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return [Default.AsynchronousOperation.KeyPath.State]
    }

    
    // MARK: Operation Methods
    public final override func start() {
        super.start()
        guard !isCancelled else {
            finish()
            return
        }
        
        state = .executing
        execute()
    }
    
    
    open func execute() {
        fatalError(Error_.AsynchronousOperation.ExecuteMethodNotImplemented.localizedDescription)
    }
    
    
    public final func finish() {
        // Call it on async task completion to mark the completion of the operation.
        state = .finished
    }
    
}


public extension Default.DispatchQueue_.Label {
    static let AsynchronousOperation = Default.DispatchQueue_.Label.Main + "." + "AsyncOp"
}


public extension Default {
    enum AsynchronousOperation {
        enum KeyPath {
            static let State = "state"
        }
    }
}


public extension Error_ {
    
    enum AsynchronousOperation: Error {
        case ExecuteMethodNotImplemented
        
        var localizedDescription: String {
            let description : String
            switch self {
                
            case .ExecuteMethodNotImplemented:
                description = "Subclass must implement execute method"
                
            }
            
            return description
        }
    
    }
    
}
