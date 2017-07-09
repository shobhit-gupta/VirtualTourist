//
//  Photo+Ease.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 01/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public extension Photo {

    convenience init(url: URL, pin: Pin, insertInto context: NSManagedObjectContext) {
        self.init(entity: Photo.entity(), insertInto: context)
        self.url = url.absoluteString
        self.pin = pin
    }
    
    
    func verifyAspectRatio() {
        guard let data = image, let img = UIImage(data: data as Data), img.size.height > 0 else {
            return
        }
        let newAspectRatio = Float(img.size.width / img.size.height)
        if aspectRatio != newAspectRatio {
            aspectRatio = newAspectRatio
        }
    }

}

