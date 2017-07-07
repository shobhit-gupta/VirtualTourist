//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 07/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit

class AlbumViewController: UICollectionViewController {
    
    // MARK: Dependencies
    public var coreDataManager: CoreDataManager!
    public var downloadQueue: OperationQueue!
    public var pin: Pin!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}



extension AlbumViewController {
    
    class func storyboardInstance() -> AlbumViewController? {
        let storyboard = UIStoryboard(name: Default.FileName.MainStoryboard, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as? AlbumViewController
    }
    
}
