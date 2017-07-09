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
    
    
    // MARK: IBOutlets
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    // MARK: Private variables and types
    fileprivate var space: CGFloat {
        // space = 1.0 for minimum width on iOS
        return round((collectionView?.bounds.width ?? 1.0) / Default.General.iOSMinWidth)
    }
    
    fileprivate var numCellsOnSmallerSide: Int {
        if let collectionView = collectionView {
            let smallerSideLength = min(collectionView.bounds.width, collectionView.bounds.height)
            let approxCellDimension = Default.General.iOSMinWidth / CGFloat(Default.GridView.NumCellsOnSmallestSide)
            return Int(round(smallerSideLength / approxCellDimension))
        }
        return Default.GridView.NumCellsOnSmallestSide
    }
    
    fileprivate lazy var numberOfCellsInRow: Int = self._numberOfCellsInRow(for: self.collectionView!)
    fileprivate lazy var cellDimension: CGFloat = self._cellDimension(for: self.collectionView!)
    
    
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
    
    fileprivate var downloadPhotoOperations = [DownloadPhoto]() {
        didSet {
            if refreshButton.isEnabled == false && downloadPhotoOperations.count == 0 {
                DispatchQueue.main.async {
                    self.refreshButton.isEnabled = true
                }
            } else if refreshButton.isEnabled == true && downloadPhotoOperations.count > 0 {
                DispatchQueue.main.async {
                    self.refreshButton.isEnabled = false
                }
            }
        }
    }

    fileprivate lazy var processFetchedResultOps = [BlockOperation]()
    
    
    // MARK: Standard callbacks
    deinit {
        processFetchedResultOps.forEach { $0.cancel() }
        processFetchedResultOps.removeAll()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    override func viewDidLayoutSubviews() {
        if let collectionView = collectionView {
            numberOfCellsInRow = _numberOfCellsInRow(for: collectionView)
            cellDimension = _cellDimension(for: collectionView)
        }
    }
    
    
    // To make the app feel more responsive, make sure that the AlbumView that
    // the user is currently viewing, downloads it's requested photos at higher
    // priority.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        downloadPhotoOperations.forEach {
            if !$0.isFinished {
                $0.queuePriority = .normal
            }
        }
        collectionView?.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        downloadPhotoOperations.forEach {
            if !$0.isFinished {
                $0.queuePriority = .low
            }
        }
    }
    
    
    func printOnMain(_ str: String) {
        DispatchQueue.main.async {
            print(str)
        }
    }


    @IBAction func refresh(_ sender: Any) {
        downloadPhotoOperations.forEach {
            $0.cancel()
        }
        
        if let photos = pin.photos {
            photos.forEach({
                if let photo = $0 as? Photo {
                    coreDataManager.mainManagedObjectContext.delete(photo)
                }
            })
        }
        
        downloadMOC.reset()
        getPhotoURLs()
    }
    
}


//******************************************************************************
//                                  MARK: Setup
//******************************************************************************
fileprivate extension AlbumViewController {
    
    private var shouldGetPhotoURLs: Bool {
        var decision = true
        if let photos = pin.photos {
            decision = photos.count == 0
        }
        return decision
    }
    
    
    func setup() {
        setupDataSource()
        setupUI()
    }
    
    private func setupDataSource() {
        do {
            try fetchedPhotosController.performFetch()
            if shouldGetPhotoURLs {
                getPhotoURLs()
            }
            
        } catch {
            print(error.info())
        }
    }
    
    
    private func setupUI() {
        if shouldGetPhotoURLs || downloadPhotoOperations.count > 0 {
            refreshButton.isEnabled = false
        }
    }
    
    
}


//******************************************************************************
//                                MARK: Operations
//******************************************************************************
fileprivate extension AlbumViewController {
    
    func getPhotoURLs() {
        if let getPhotoURLsOp = self.coreDataManager.getPhotoURLs(for: self.pin.objectID, withContext: self.downloadMOC, inQueue: self.downloadQueue) {
            getPhotoURLsOp.completionBlock = {
                DispatchQueue.main.async { [weak self] in
                    guard let s = self else { return }
                    if let photos = s.pin.photos, photos.count == 0 {
                        s.navigationItem.prompt = "0 photos found"
                    }
                }
            }
        }
    }
    
    
    func download(photo: Photo) {
        guard photo.downloadQueued == false else {
            return
        }
        
        if let downloadPhotoOp = self.coreDataManager.downloadPhoto(id: photo.objectID, withContext: self.downloadMOC, inQueue: self.downloadQueue) {
            // Mark that photo is queued for download
            photo.downloadQueued = true
            
            // Ensure that the operation will be removed after it is completed
            // from the stored array.
            downloadPhotoOp.completionBlock = {
                if let idx = self.downloadPhotoOperations.index(of: downloadPhotoOp) {
                    self.downloadPhotoOperations.remove(at: idx)
                }
            }
            
            // Add operation to stored array so that we can change it's priority
            // later depending upon the user's actions.
            self.downloadPhotoOperations.append(downloadPhotoOp)
        }
        
    }
    
}


//******************************************************************************
//                  MARK: Fetched Results Controller Delegate
//******************************************************************************
extension AlbumViewController: NSFetchedResultsControllerDelegate {
    
    private func addFetchedResultsOp(for processingBlock: @escaping () -> Void) {
        processFetchedResultOps.append(BlockOperation(block: processingBlock))
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({ 
            self.processFetchedResultOps.forEach({ $0.start() })
        }, completion: { (finished) in
            self.processFetchedResultOps.removeAll(keepingCapacity: false)
            self.coreDataManager?.save()
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
            
        case .delete:
            if let indexPath = indexPath, let collectionView = collectionView {
                addFetchedResultsOp {
                    collectionView.deleteItems(at: [indexPath])
                }
            }
            
        default:
            break
        }
        
    }

}


//******************************************************************************
//                         MARK: Collection View Data Source
//******************************************************************************
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
            cell.image = image
            cell.layer.cornerRadius = Default.GridViewCell.CornerRadius
        
        } else if photo.downloadInitiated {
            cell.progress = photo.downloadedFraction
        
        } else if !photo.downloadQueued {
            // Lazily download photos. Also, make sure that the download is not 
            // already queued.
            cell.progress = nil
            download(photo: photo)
        }
    }
    
}


//******************************************************************************
//                  MARK: Collection View Delegate Flow Layout
//******************************************************************************
extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    
    fileprivate func _numberOfCellsInRow(for collectionView: UICollectionView) -> Int {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return width < height ? numCellsOnSmallerSide : Int(CGFloat(numCellsOnSmallerSide) * width / height)
    }
    
    
    fileprivate func _cellDimension(for collectionView: UICollectionView) -> CGFloat {
        let width = collectionView.frame.width
        let numCells = CGFloat(numberOfCellsInRow)
        let emptySpace = (numCells + 1) * space
        return (width - emptySpace) / numCells
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = cellDimension
        var width = dimension
        var height = dimension
        
        if numCellsOnSmallerSide > Default.GridView.NumCellsOnSmallestSide {
            
            let aspectRatio = CGFloat(fetchedPhotosController.object(at: indexPath).aspectRatio)
            if aspectRatio > Default.GridViewCell.AspectRatio.TooWide {
                height /= Default.GridViewCell.AspectRatio.TooWide
                
            } else if aspectRatio > Default.GridViewCell.AspectRatio.Square {
                height /= aspectRatio
                
            } else if aspectRatio < Default.GridViewCell.AspectRatio.TooNarrow {
                width *= Default.GridViewCell.AspectRatio.TooNarrow
                
            } else {
                width *= aspectRatio
            }
            
        }
        
        return CGSize(width: width, height: height)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2 * space
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let space = self.space
        return UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
}


//******************************************************************************
//                      MARK: View Controller instantiation
//******************************************************************************
extension AlbumViewController {
    
    class func storyboardInstance() -> AlbumViewController? {
        let storyboard = UIStoryboard(name: Default.FileName.MainStoryboard, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as? AlbumViewController
    }
    
}
