//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 20/02/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit
import MapKit
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
    
    
    // MARK: Standard callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupUI()
        //printStat(self)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func printOnMain(_ str: String) {
        DispatchQueue.main.async {
            print(str)
        }
    }
    

//    func printStat(_ sender: Any) {
//        let photofetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//        let pinFetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//        
//        do {
//            let numPhotos = try coreDataManager.mainManagedObjectContext.count(for: photofetchRequest)
//            let numPins = try coreDataManager.mainManagedObjectContext.count(for: pinFetchRequest)
//            printOnMain("Context: \(coreDataManager.mainManagedObjectContext) Num photos: \(numPhotos) Num pins: \(numPins)")
//        } catch {
//            
//        }
//        
//    }

}


//******************************************************************************
//                                  MARK: Setup
//******************************************************************************
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


//******************************************************************************
//                                  MARK: Actions
//******************************************************************************
fileprivate extension TravelLocationsMapViewController {
    
    @objc func mapViewLongPressed(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .ended:
            // Get coordinate of the point pressed
            let touchPoint = sender.location(in: mapView)
            let location = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            addPin(for: location)
            
        default:
            break
        }
    }
    
    
    private func addPin(for location: CLLocationCoordinate2D) {
        let _ = Pin(location: location, insertInto: coreDataManager.mainManagedObjectContext)
    }
    
    
}


//******************************************************************************
//                  MARK: Fetched Results Controller Delegate
//******************************************************************************
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
            let pinAnnotation = pin.createAnnotation()
            mapView.addAnnotation(pinAnnotation)
            
        default:
            break
        }
    }

}


//******************************************************************************
//                          MARK: Map View Delegate
//******************************************************************************
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
        
        segueToAlbum(withPinId: pinAnnotation.pinId)
        
        defer {
            mapView.deselectAnnotation(pinAnnotation, animated: true)
        }
    }

}


//******************************************************************************
//                      MARK: View Controller instantiation
//******************************************************************************
extension TravelLocationsMapViewController {
    
    fileprivate func segueToAlbum(withPinId pinId: NSManagedObjectID) {
        guard let albumViewController = AlbumViewController.storyboardInstance(),
            let pin = coreDataManager.mainManagedObjectContext.object(with: pinId) as? Pin  else {
                return
        }
        
        // Inject dependencies
        albumViewController.coreDataManager = coreDataManager
        albumViewController.downloadQueue = downloadQueue
        albumViewController.pin = pin
        
        // Present
        if let navigationController = navigationController {
            navigationController.pushViewController(albumViewController, animated: true)
        } else {
            present(albumViewController, animated: true, completion: nil)
        }
        
    }
    
    
    public class func storyboardInstance() -> TravelLocationsMapViewController? {
        let storyboard = UIStoryboard(name: Default.FileName.MainStoryboard, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "TravelLocationsMapViewController") as? TravelLocationsMapViewController
    }
    
}
