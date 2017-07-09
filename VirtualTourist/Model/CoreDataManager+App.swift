//
//  CoreDataManager+App.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 08/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
import CoreData


public extension CoreDataManager {
    
    internal func getPhotoURLs(for pinId: NSManagedObjectID, withContext context: NSManagedObjectContext, inQueue queue: OperationQueue) -> GetPhotoURLsForPin? {
        guard let getPhotoURLsOp = GetPhotoURLsForPin(withId: pinId, in: context) else {
            return nil
        }
        getPhotoURLsOp.queuePriority = Default.AsynchronousOperation.GetPhotoURLsForPin.QueuePriority
        queue.addOperation(getPhotoURLsOp)
        return getPhotoURLsOp
    }
    
    
    internal func downloadPhoto(id photoId: NSManagedObjectID, withContext context: NSManagedObjectContext, inQueue queue: OperationQueue) -> DownloadPhoto? {
        guard let downloadPhotoOp = DownloadPhoto(withId: photoId, in: context) else {
            return nil
        }
        downloadPhotoOp.queuePriority = Default.AsynchronousOperation.DownloadPhoto.QueuePriority
        queue.addOperation(downloadPhotoOp)
        return downloadPhotoOp
    }
    
}
