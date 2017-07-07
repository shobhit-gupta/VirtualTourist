//
//  Pin+Ease.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 30/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit


public extension Pin {
    
    public var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    

    convenience init(location: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: context) else {
            fatalError("Unable to find entity name: Pin")
        }
        self.init(entity: entityDescription, insertInto: context)
        // TODO: Try this instead
        // self.init(entity: Pin.entity(), insertInto: context)
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
    
    
    public func createAnnotation() -> PinAnnotation {
        return PinAnnotation(pin: self)
    }
    

}
