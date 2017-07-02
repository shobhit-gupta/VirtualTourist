//
//  GetPhotoURLsForPin.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 29/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class GetPhotoURLsForPin: Operation {
    
    // MARK: Public variables and types
    public let pin: Pin
    
    
    // MARK: Private variables and types
    private let managedObjectContext: NSManagedObjectContext
    
    
    // MARK: Initializers
    init(_ pin: Pin, withContext context: NSManagedObjectContext) {
        managedObjectContext = context
        self.pin = pin
        super.init()
    }
    
    
    init(withLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, context: NSManagedObjectContext) {
        managedObjectContext = context
        pin = Pin(latitude: latitude, longitude: longitude, insertInto: context)
        super.init()
    }
    
    
    // MARK: Operation Methods
    override func main() {
        Flickr.randomSearch(latitude: pin.latitude, longitude: pin.longitude) { (success, json, error) in
            guard success, error == nil, let json = json else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            // Construct photos with returned urls. Though download them later on according to need.
            Flickr.getPhotoURLs(from: json).forEach {
                let photo = Photo(url: $0, insertInto: self.managedObjectContext)
                photo.pin = self.pin
            }
        }
        
        // Save private child context. Changes will be pushed to the main context.
        managedObjectContext.performAndWait {
            self.managedObjectContext.saveChanges()
        }
    }
    
    
}
