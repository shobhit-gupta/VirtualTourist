//
//  Photo+Ease.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 01/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
import CoreData


public extension Photo {

    convenience init(url: URL, pin: Pin, insertInto context: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: context) else {
            fatalError("Unable to find entity name: Photo")
        }
        self.init(entity: entityDescription, insertInto: context)
        self.url = url.absoluteString
        self.pin = pin
        
    }

}

