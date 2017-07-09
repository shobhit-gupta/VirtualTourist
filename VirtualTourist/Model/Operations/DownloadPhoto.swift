//
//  DownloadPhoto.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 03/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


class DownloadPhoto: AsynchronousOperation {

    // MARK: Private variables and types
    fileprivate let photo: Photo
    fileprivate let managedObjectContext: NSManagedObjectContext
    fileprivate var numberOfTries = 0
    
    
    init?(withId id: NSManagedObjectID, in context: NSManagedObjectContext) {
        guard let photo = context.object(with: id) as? Photo else {
            return nil
        }
        managedObjectContext = context
        self.photo = photo
        super.init()
    }
    
    
    // MARK: Operation Methods
    override func execute() {
        guard let urlString = photo.url, let url = URL(string: urlString) else {
            print("Photo url not found")
            return
        }
        downloadPhoto(from: url)
    }
    
}


fileprivate extension DownloadPhoto {

    func downloadPhoto(from url: URL) {
        guard !self.isCancelled else {
            self.finish()
            return
        }
        
        guard numberOfTries < 4 else {
            print("Max retries reached")
            finish()
            return
        }
        
        numberOfTries += 1
        
        Alamofire.request(url)
            .downloadProgress(queue: .main) { (progress) in
                guard !self.isCancelled else {
                    self.finish()
                    return
                }
                
                if self.photo.downloadInitiated == false {
                    self.photo.downloadInitiated = true
                    self.managedObjectContext.performAndWait {
                        self.managedObjectContext.saveChanges()
                    }
                }
                
                let fractionDone = Float(progress.fractionCompleted)
                if fractionDone - self.photo.downloadedFraction > 0.1 {
                    self.photo.downloadedFraction = fractionDone
                    self.managedObjectContext.performAndWait {
                        self.managedObjectContext.saveChanges()
                    }
                }
                
            }
            .responseData { (response) in
                guard !self.isCancelled else {
                    self.finish()
                    return
                }

                switch response.result {
                
                case .failure(let error):
                    print(error.info())
                    self.downloadPhoto(from: url)
                    
                case .success(let value):
                    // Store the downloaded image.
                    self.photo.image = value as NSData
                    self.photo.verifyAspectRatio()
                    
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
