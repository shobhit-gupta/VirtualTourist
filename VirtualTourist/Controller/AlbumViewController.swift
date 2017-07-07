//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 07/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class AlbumViewController: UICollectionViewController {
    
    // MARK: Dependencies
    public var coreDataManager: CoreDataManager!
    public var downloadQueue: OperationQueue!
    public var pin: Pin!
    
    
    // MARK: Private variables and types
    fileprivate lazy var fetchedPhotosController: NSFetchedResultsController<Photo> = {
        let photoFetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        photoFetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        photoFetchRequest.predicate = NSPredicate(format: "pin = %@", self.pin)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: photoFetchRequest,
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
    }


}


//******************************************************************************
//                                  MARK: Setup
//******************************************************************************
fileprivate extension AlbumViewController {
    
    func setupDataSource() {
        do {
            try fetchedPhotosController.performFetch()
        } catch {
            print(error.info())
        }
    }
    
    
    func setupUI() {
        print("Num Photos: \(fetchedPhotosController.fetchedObjects?.count ?? 0)")
    }
    
    
}



extension AlbumViewController: NSFetchedResultsControllerDelegate {}


// Data source
extension AlbumViewController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AlbumViewMapHeader", for: indexPath) as? HeaderCollectionReusableView else {
                fatalError()
        }
        
        headerView.showCoordinate(pin.location)
        headerView.mapView.addAnnotation(pin.createAnnotation())
        return headerView
    }
    
    
}


extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100.0)
    }
    
}


extension AlbumViewController {
    
    class func storyboardInstance() -> AlbumViewController? {
        let storyboard = UIStoryboard(name: Default.FileName.MainStoryboard, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as? AlbumViewController
    }
    
}
