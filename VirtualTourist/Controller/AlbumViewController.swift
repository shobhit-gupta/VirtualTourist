//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 07/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
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
    
    
    fileprivate lazy var downloadMOC: NSManagedObjectContext = {
        return self.coreDataManager.privateChildManagedObjectContext()
    }()
    
    
    fileprivate lazy var processFetchedResultOps = [BlockOperation]()
    
    
    deinit {
        processFetchedResultOps.forEach { $0.cancel() }
        processFetchedResultOps.removeAll()
    }
    
    
    // MARK: Standard callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupUI()
    }
    
    
    func printOnMain(_ str: String) {
        DispatchQueue.main.async {
            print(str)
        }
    }


}


//******************************************************************************
//                                  MARK: Setup
//******************************************************************************
fileprivate extension AlbumViewController {
    
    func setupDataSource() {
        do {
            try fetchedPhotosController.performFetch()
            if fetchedPhotosController.fetchedObjects?.count == 0 {
                getPhotoURLs()
            }
            
        } catch {
            print(error.info())
        }
    }
    
    
    func setupUI() {
        print("Num Photos: \(fetchedPhotosController.fetchedObjects?.count ?? 0)")
    }
    
    
}


fileprivate extension AlbumViewController {
    
    func getPhotoURLs() {
        if let getPhotoURLsOp = GetPhotoURLsForPin(withId: pin.objectID, in: downloadMOC) {
            downloadQueue.addOperation(getPhotoURLsOp)
        }
    }
    
    
    func download(photo: Photo) {
        if let downloadPhotoOp = DownloadPhoto(withId: photo.objectID, in: downloadMOC, progressHandler: { (fraction) in
            
        }) {
            downloadQueue.addOperation(downloadPhotoOp)
        }
    }
    
}


extension AlbumViewController: NSFetchedResultsControllerDelegate {
    
    private func addFetchedResultsOp(for processingBlock: @escaping () -> Void) {
        processFetchedResultOps.append(BlockOperation(block: processingBlock))
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({ 
            self.processFetchedResultOps.forEach({ $0.start() })
        }, completion: { (finished) in
            self.processFetchedResultOps.removeAll(keepingCapacity: false)
        })
    }
    

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard controller === fetchedPhotosController else {
            return
        }
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath, let collectionView = collectionView {
                addFetchedResultsOp {
                    collectionView.insertItems(at: [newIndexPath])
                }
            }
            
        case .update:
            if let indexPath = indexPath, let collectionView = collectionView {
                addFetchedResultsOp {
                    collectionView.reloadItems(at: [indexPath])
                }
            }
            
        default:
            break
        }
        
    }

}


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
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? fetchedPhotosController.fetchedObjects?.count ?? 0 : 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as? AlbumViewCell else {
            fatalError()
        }
        configure(cell, at: indexPath)
        return cell
    }
    
    
    fileprivate func configure(_ cell: AlbumViewCell, at indexPath: IndexPath) {
        let photo = fetchedPhotosController.object(at: indexPath)
        if let imageData = photo.image,
            let image = UIImage(data: imageData as Data) {
            cell.imageView.image = image
        } else {
            download(photo: photo)
        }
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
