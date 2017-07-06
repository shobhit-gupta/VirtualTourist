//
//  Error_+Flickr.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 18/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation


public extension Error_ {
    
    enum Flickr: Error {
        case InvalidURL(sender: Any.Type)
        
        var localizedDescription: String {
            let description : String
            switch self {
                
            case .InvalidURL(let sender):
                description = "Couldn't construct url for Flickr API: \(sender)"
                
            }
            
            return description
        }
    }
    
}
