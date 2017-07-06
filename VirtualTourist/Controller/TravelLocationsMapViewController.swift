//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 20/02/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import CoreData


class TravelLocationsMapViewController: UIViewController {

    // MARK: Public variables and types
    public var coreDataManager: CoreDataManager!
    public var downloadQueue: OperationQueue!
    
    
    override func viewDidLoad() {
        print("TravelLocationsMapView initialized")
        super.viewDidLoad()
        
        printStat(self)
        
        for _ in stride(from: 0, to: 10, by: 1) {
            
            // Generate random latiude and longitude
            let latitude = 31.1048//Double.random(lower: -90.0, upper: 90.0)
            let longitude = 77.1734//Double.random(lower: -180.0, upper: 180.0)
            print("New Random coordinate: Latitude: \(latitude), Longitude: \(longitude)")
            
            // Generate Pin
            let pin = Pin(latitude: latitude, longitude: longitude, insertInto: coreDataManager.mainManagedObjectContext)
            
            // GetPhotoURLsForPin
            let downloadMOC = coreDataManager.privateChildManagedObjectContext()
            if let getPhotoURLsOp = GetPhotoURLsForPin(withId: pin.objectID, in: downloadMOC, queue: downloadQueue) {
                
//                getPhotoURLsOp.completionBlock = {
                    // On completion of previous op, add DownloadPhoto op
//
//                    self.printOnMain("Photo URLs \(pin.photos?.count ?? 0) fetch completed for pin: \(pin.objectID)")
//                    
//
//                    if let photos = pin.photos {
//                        photos.forEach({ (photo) in
//                            guard let photo = photo as? Photo else {
//                                self.printOnMain("Here is the issue")
//                                return
//                            }
//                            if let downloadPhotoOp = DownloadPhoto(withId: photo.objectID, in: downloadMOC, progressHandler: { (fraction) in
//                                self.printOnMain("Download Progress: \(fraction * 100)% of \(photo.objectID)")
//                            }) {
//                                
//                                downloadPhotoOp.completionBlock = {
//                                    self.printOnMain("Download completed for photo: \(photo.objectID)")
//                                }
//                                
//                                self.printOnMain("Add downloadPhotoOp for photo: \(photo.objectID)")
//                                downloadQueue.addOperation(downloadPhotoOp)
//                            }
//                        })
//                    }
//                    
//
//                }
                
                printOnMain("Add getPhotoURLsOp for pin: \(pin.objectID)")
                downloadQueue.addOperation(getPhotoURLsOp)
            }
        

        }
        
//        addObserver(self, forKeyPath: #keyPath(downloadQueue.operationCount), options: [.old, .new], context: nil)
//        
//        let q = DispatchQueue(label: "coreDataSave", qos: .utility)
//        let t = DispatchTime.now() + .seconds(10)
//        q.asyncAfter(deadline: t) {
//            self.printOnMain("======> Put wait")
//            self.downloadQueue.waitUntilAllOperationsAreFinished()
//            self.printOnMain("======> End wait")
//            self.coreDataManager.save()
//            
//        }
//        
//        printOnMain("=====> Outside wait")
        
        
        
        
//        Flickr.randomSearch(latitude: 31.1048, longitude: 77.1734) { (success, json, error) in
//            
//            guard success, error == nil, let json = json else {
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//                return
//            }
//            
//            print("\n\n=========================================\n\(json)")
//        }
        
    }

    func printOnMain(_ str: String) {
        DispatchQueue.main.async {
            print(str)
        }
    }
    

    @IBAction func printStat(_ sender: Any) {
        let photofetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let pinFetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let numPhotos = try coreDataManager.mainManagedObjectContext.count(for: photofetchRequest)
            let numPins = try coreDataManager.mainManagedObjectContext.count(for: pinFetchRequest)
            printOnMain("Context: \(coreDataManager.mainManagedObjectContext) Num photos: \(numPhotos) Num pins: \(numPins)")
        } catch {
            
        }
        
    }

}

