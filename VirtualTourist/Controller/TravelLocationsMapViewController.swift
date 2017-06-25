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


class TravelLocationsMapViewController: UIViewController {

    // MARK: Public variables and types
    public var coreDataManager: CoreDataManager!
    
    
    override func viewDidLoad() {
        print("TravelLocationsMapView initialized")
        super.viewDidLoad()
        
        print(coreDataManager.mainManagedObjectContext)
        Flickr.randomSearch(latitude: 31.1048, longitude: 77.1734) { (success, json, error) in
            
            guard success, error == nil, let json = json else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            print("\n\n=========================================\n\(json)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

