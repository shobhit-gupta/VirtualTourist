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

    // MARK: Dependencies
    public var coreDataManager: CoreDataManager!
    public var downloadQueue: OperationQueue!
    
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Private variables and types
    fileprivate lazy var fetchedPinsController: NSFetchedResultsController<Pin> = {
        let pinFetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        pinFetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: pinFetchRequest,
                                                                  managedObjectContext: self.coreDataManager.mainManagedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupUI()
        
        printStat(self)
        
//        for _ in stride(from: 0, to: 10, by: 1) {
//
            // Generate random latiude and longitude
//            let latitude = Double.random(lower: -90.0, upper: 90.0)
//            let longitude = Double.random(lower: -180.0, upper: 180.0)
//            print("New Random coordinate: Latitude: \(latitude), Longitude: \(longitude)")
//            
//            // Generate Pin
//            let pin = Pin(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), insertInto: coreDataManager.mainManagedObjectContext)
            
            // GetPhotoURLsForPin
//            let downloadMOC = coreDataManager.privateChildManagedObjectContext()
//            if let getPhotoURLsOp = GetPhotoURLsForPin(withId: pin.objectID, in: downloadMOC, queue: downloadQueue) {
            
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
                
//                printOnMain("Add getPhotoURLsOp for pin: \(pin.objectID)")
//                downloadQueue.addOperation(getPhotoURLsOp)
//            }
        

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


fileprivate extension TravelLocationsMapViewController {
    
    func setupDataSource() {
        // Fetch all the pins from coredata
        do {
            try fetchedPinsController.performFetch()
        } catch {
            print(error.info())
        }
    }
    
    
    func setupUI() {
        setupMapView()
    }
    
    
    private func setupMapView() {
        mapView.delegate = self
        addAnnotations()
        addLongPressGesture()
    }
    
    // Add annotations for fetched pins to the map
    private func addAnnotations() {
        if let annotations = fetchedPinsController.fetchedObjects?.map({ $0.createAnnotation() }) {
            mapView.addAnnotations(annotations)
        }
    }
    
    // Add a longPressGesture to mapView
    private func addLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongPressed(sender:)))
        mapView.addGestureRecognizer(longPress)
    }
    
    
}


fileprivate extension TravelLocationsMapViewController {
    
    @objc func mapViewLongPressed(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .ended:
            // Get coordinate of the point pressed
            let touchPoint = sender.location(in: mapView)
            let location = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            addPin(for: location)
            //getPhotoURLs(for: pin)
            
        default:
            break
        }
    }
    
    
    func addPin(for location: CLLocationCoordinate2D) {
        let _ = Pin(location: location, insertInto: coreDataManager.mainManagedObjectContext)
    }
    
    
    func getPhotoURLs(for pin: Pin) {
        let downloadMOC = coreDataManager.privateChildManagedObjectContext()
        if let getPhotoURLsOp = GetPhotoURLsForPin(withId: pin.objectID, in: downloadMOC) {
            downloadQueue.addOperation(getPhotoURLsOp)
        }
    }
    
}

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard controller === fetchedPinsController else {
            return
        }
        
        switch type {
        case .insert:
            guard let pin = anObject as? Pin else {
                return
            }
            mapView.addAnnotation(pin.createAnnotation())
            print("Annotation added for a new pin at: \(pin.latitude), \(pin.longitude)")
            
        default:
            break
        }
    }

}


extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.animatesDrop = true
        return annotationView
    }
    

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let pinAnnotation = view.annotation as? PinAnnotation else {
            return
        }
        print(">>>>>>>>>>. Selected pin: \(pinAnnotation.pinId) <<<<<<<<<<<<")
        
        defer {
            mapView.deselectAnnotation(pinAnnotation, animated: true)
        }
    }

}


extension TravelLocationsMapViewController {
    
    class func storyboardInstance() -> TravelLocationsMapViewController? {
        let storyboard = UIStoryboard(name: Default.FileName.MainStoryboard, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "TravelLocationsMapViewController") as? TravelLocationsMapViewController
    }
    
}
