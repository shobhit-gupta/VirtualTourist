//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 06/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import CoreData
import MapKit


public class PinAnnotation: MKPointAnnotation {
    
    let pinId: NSManagedObjectID
    
    init(pin: Pin) {
        self.pinId = pin.objectID
        super.init()
        coordinate = pin.location
    }
    
}
