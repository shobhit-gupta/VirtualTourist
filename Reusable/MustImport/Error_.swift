//
//  Error_.swift
//  PitchPerfect
//
//  Created by Shobhit Gupta on 25/03/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
import UIKit


public enum Error_ {
    // Extend Error_ in individual files.
    // Then import this file along with specific files that need to be reused in future projects.
}

// Add/Remove or Comment/Uncomment nested enums according to which piece of code you reuse.
public extension Error_ {
    enum Audio {}
    enum Network {}
}


public extension Error {
    
    public func info() -> String {
        let description: String
        let objectDescription = String(describing: self)
        let localizedDescription = self.localizedDescription
        
        if localizedDescription == ""  || objectDescription.contains(localizedDescription) {
            description = objectDescription
        } else if localizedDescription.contains(objectDescription) {
            description = localizedDescription
        } else {
            description = objectDescription + ": " + localizedDescription
        }
        
        return description
    }
    
}


public extension Error_ {
    
    enum General: Error {
        case DowncastMismatch(for: Any?, as: Any.Type)
        case ReusableViewDequeFailed(identifier: String, viewType: UIView.Type)
        case UnexpectedSegue(identifier: String?)
        case UnexpectedSegueDestination(identifier: String?, destination: UIViewController.Type, expected: UIViewController.Type)
        case UnexpectedSegueSender(identifier: String?, sender: Any.Type, expected: Any.Type)
        case UnexpectedCurrentState(state: String)
        
        var localizedDescriptionVerbose: String {
            let description = String(describing: self) + " " + localizedDescription
            return description
        }
        
        // TODO: Use localized String xml file (Maybe later if there's a need for it.)
        var localizedDescription: String {
            let description : String
            switch self {
            case let .DowncastMismatch(object, type):
                description = "\(String(describing: object)) couldn't be downcasted as \(type)"
                
            case let .ReusableViewDequeFailed(identifier, viewType):
                description = "Failed to deque reusable view of type: \(viewType) with reuse id: \(identifier)"
                
            case .UnexpectedSegue(let identifier):
                description = "Unexpected Segue Identifier Encounterd: \(String(describing: identifier))"
                
            case let .UnexpectedSegueDestination(identifier, destination, expected):
                description = "Segue Identifier: \(String(describing: identifier)) expected \(expected) destination. Received: \(destination)"
                
            case let .UnexpectedSegueSender(identifier, sender, expected):
                description = "Segue Identifier: \(String(describing: identifier)) expected \(expected) sender. Received: \(sender)"
                
            case .UnexpectedCurrentState(let state):
                description = "Unexpected current state: " + state
                
            }
            
            return description
        }
    }
    
}
