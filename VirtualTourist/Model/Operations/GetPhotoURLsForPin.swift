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


class GetPhotoURLsForPin: AsynchronousOperation {
    
    // MARK: Private variables and types
    private let pin: Pin
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: Initializers
    init?(withId id: NSManagedObjectID, in context: NSManagedObjectContext) {
        guard let pin = context.object(with: id) as? Pin else {
            return nil
        }
        managedObjectContext = context
        self.pin = pin
        super.init()
    }
    
    
    // MARK: Operation Methods
    override func execute() {
        Flickr.randomSearch(latitude: pin.latitude, longitude: pin.longitude) { (success, json, error) in
            guard success, error == nil, let json = json else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            // Construct photos with returned urls. Though download them later on according to need.
            let photosInfo = Flickr.getPhotosInfo(from: json)
            
            photosInfo.forEach {
                let photo = Photo(url: $0.url, pin: self.pin, insertInto: self.managedObjectContext)
                if let width = $0.width, let height = $0.height {
                    photo.aspectRatio = width / height
                }
                self.pin.addToPhotos(photo)
            }
            
//            self.printOnMain("Photo URLs \(self.pin.photos?.count ?? 0) fetch completed for pin: \(self.pin.objectID)")
            
            defer {
                // Save private child context. Changes will be pushed to the main context.
                self.managedObjectContext.performAndWait {
                    self.managedObjectContext.saveChanges()
                }
                
                // Mark the operation finished
                self.finish()
            }
            
        }
        
    }
    
    
    func printOnMain(_ str: String) {
        DispatchQueue.main.async {
            print(str)
        }
    }
    
}
