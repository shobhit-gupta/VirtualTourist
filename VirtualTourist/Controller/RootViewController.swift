//
//  RootViewController.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 27/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

//  Reusable RootViewController Pattern
//  ----------------------------------------------------------------------------
//  It is a container view controller and should remain alive throughout the 
//  app's life, and thus serves as a great place to add dependency injections 
//  and instantiate view controllers. This should reduce the complexity of app 
//  delegate in more complex apps.

//  References:
//  https://developer.apple.com/videos/play/wwdc2011/102/
//  https://cocoacasts.com/managing-view-controllers-with-container-view-controllers/
//  https://cocoacasts.com/building-the-perfect-core-data-stack-give-it-time/



import UIKit


class RootViewController: UIViewController {

    // MARK: Dependency Injections
    internal var coreDataManager: CoreDataManager?
    
    
    // MARK: Child View Controllers
    // IMPORTANT: Do not forget to add these as child view controller with addChild(_:) method
    public private(set) lazy var travelLocationsMapVC: TravelLocationsMapViewController = self.instantiateViewController(identifier: "TravelLocationsMapViewController", classType: TravelLocationsMapViewController.self)
    
    
    private func instantiateViewController<T: UIViewController>(identifier: String, classType: T.Type) -> T {
        let storyboard = UIStoryboard(name: Default.FileName.MainStoryboard, bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return viewController
    }

    
    // MARK: Viewcontroller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoreData()
    }

}


fileprivate extension RootViewController {

    func setupCoreData() {
        let coreDataCompletion = {
            self.setupView()
        }
        
        if let _ = coreDataManager {
            coreDataCompletion()
            
        } else {
            coreDataManager = CoreDataManager(modelName: Default.FileName.DataModel,
                                              ofType: .withPrivatePersistentQueue,
                                              completion: coreDataCompletion)
        }
    
    }
    
    
    private func setupView() {
        setupTravelLocationsMapViewController()
        updateView()
    }
    
    
    private func setupTravelLocationsMapViewController() {
        if let coreDataManager = coreDataManager {
            travelLocationsMapVC.coreDataManager = coreDataManager
            addChild(travelLocationsMapVC)
        }
    }
    
    // Leave blank if not required
    private func updateView() {
        
    }
    
}


// Use View Controller Containment API to ensure that appearance callbacks of
// child view controller, such as viewWillAppear etc. are called.
fileprivate extension RootViewController {
    
    func addChild(_ child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.didMove(toParentViewController: self)
    }
    
    
    func removeChild(_ child: UIViewController) {
        child.willMove(toParentViewController: nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }
    
}
