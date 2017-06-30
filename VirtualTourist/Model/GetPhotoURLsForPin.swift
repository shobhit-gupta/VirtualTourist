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
import SwiftyJSON


class GetPhotoURLsForPin: Operation {
    
    public let pin: Pin
    public private(set) var photoURLs: [URL]?
    
    private let managedObjectContext: NSManagedObjectContext
    private let shouldSaveContext: Bool
    
    init(_ pin: Pin, withContext context: NSManagedObjectContext) {
        managedObjectContext = context
        self.pin = pin
        shouldSaveContext = false
        super.init()
    }
    
    
    init(withLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, context: NSManagedObjectContext) {
        managedObjectContext = context
        pin = Pin(latitude: latitude, longitude: longitude, insertInto: context)
        shouldSaveContext = true
        super.init()
    }
    
    
    override func main() {
        Flickr.randomSearch(latitude: pin.latitude, longitude: pin.longitude) { (success, json, error) in
            guard success, error == nil, let json = json else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            self.photoURLs = Flickr.getPhotoURLs(from: json)
        }
        
        if shouldSaveContext {
            managedObjectContext.performAndWait {
                self.managedObjectContext.saveChanges()
            }
        }
    }
    
    
}
