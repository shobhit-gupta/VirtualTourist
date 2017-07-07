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
            let urlList = Flickr.getPhotoURLs(from: json)
            urlList.forEach {
                let photo = Photo(url: $0, pin: self.pin, insertInto: self.managedObjectContext)
                self.pin.addToPhotos(photo)
            }
            
            self.printOnMain("Photo URLs \(self.pin.photos?.count ?? 0) fetch completed for pin: \(self.pin.objectID)")
            
            let photofetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            let pinFetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            
            do {
                let numPhotos = try self.managedObjectContext.count(for: photofetchRequest)
                let numPins = try self.managedObjectContext.count(for: pinFetchRequest)
                self.printOnMain("Num photos: \(numPhotos) Num pins: \(numPins)")
            } catch {
                
            }
            
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
    
    
//    func downloadPhotos() {
//        if let photos = pin.photos {
//            photos.forEach({ (photo) in
//                guard let photo = photo as? Photo else {
//                    self.printOnMain("Here is the issue")
//                    return
//                }
//                if let downloadPhotoOp = DownloadPhoto(withId: photo.objectID, in: managedObjectContext, progressHandler: { (fraction) in
//                    //self.printOnMain("Download Progress: \(fraction * 100)% of \(photo.objectID)")
//                }) {
//                    self.printOnMain("Add downloadPhotoOp for photo: \(photo.objectID)")
//                    downloadQueue.addOperation(downloadPhotoOp)
//                }
//            })
//        }
//    }
    
    
    func printOnMain(_ str: String) {
        DispatchQueue.main.async {
            print(str)
        }
    }
    
}
