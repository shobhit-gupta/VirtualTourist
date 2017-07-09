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
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            willChangeValue(forKey: Default.Pin.KeyPath.Location)
            latitude = newValue.latitude
            longitude = newValue.longitude
            didChangeValue(forKey: Default.Pin.KeyPath.Location)
        }
    }
    

    convenience init(location: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        self.init(entity: Pin.entity(), insertInto: context)
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
    
    
    public func createAnnotation() -> PinAnnotation {
        return PinAnnotation(pin: self)
    }
    

}
