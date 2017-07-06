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


public extension Pin {

    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, insertInto context: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: context) else {
            fatalError("Unable to find entity name: Pin")
        }
        self.init(entity: entityDescription, insertInto: context)
        // TODO: Try this instead
        // self.init(entity: Pin.entity(), insertInto: context)
        self.latitude = latitude
        self.longitude = longitude
    }

}