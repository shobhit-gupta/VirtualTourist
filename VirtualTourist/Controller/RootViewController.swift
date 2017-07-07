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
    internal fileprivate(set) var coreDataManager: CoreDataManager?
    internal fileprivate(set) var downloadQueue: OperationQueue?
    
    
    // MARK: Child View Controllers
    // IMPORTANT: Do not forget to add these as child view controller with addChild(_:) method
    public private(set) lazy var travelLocationsMapVC: TravelLocationsMapViewController = self.instantiateViewController(identifier: "TravelLocationsMapViewController", classType: TravelLocationsMapViewController.self)
    
    
    private func instantiateViewController<T: UIViewController>(identifier: String, classType: T.Type) -> T {
        let storyboard = UIStoryboard(name: Default.FileName.MainStoryboard, bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return viewController
    }

    
    // MARK: State variables for saving on disk
    fileprivate var saveOnDiskTimer: DispatchSourceTimer?
    fileprivate var shouldStopSavingOnDisk = false
    
    
    // MARK: Standard callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(downloadQueue.operationCount), let change = change {
            guard let newValue = change[.newKey] as? Int else {
                return
            }
            
            // - If there are no operations on the downloadQueue, we should stop
            // saving on disk after making sure that everything has been saved.
            // - If we aren't saving on disk and there is a change in operationCount 
            // in downloadQueue, it is reasonably inexpensive to start saving periodically.
            if newValue == 0 {
                shouldStopSavingOnDisk = true
                
            } else if !isPeriodicallySavingOnDisk {
                periodicallySaveOnDisk()
            }
        }
    }

}


//******************************************************************************
//                                  MARK: Setup
//******************************************************************************
fileprivate extension RootViewController {
    
    func setup() {
        setupDownloadQueue()
        setupCoreData()
        subscribeToNotifications()
    }
    
    
    private func setupDownloadQueue() {
        downloadQueue = OperationQueue()
        downloadQueue?.maxConcurrentOperationCount = 3
        addObserver(self, forKeyPath: #keyPath(downloadQueue.operationCount), options: [.new], context: nil)
    }
    

    private func setupCoreData() {
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
            travelLocationsMapVC.downloadQueue = downloadQueue
            addChild(travelLocationsMapVC)
        }
    }
    
    
    // Leave blank if not required
    private func updateView() {
        
    }
    
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(_:)),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
    }
    
}


//******************************************************************************
//                      MARK: View Controller Containment
//
// Use View Controller Containment API to ensure that appearance callbacks of
// child view controller, such as viewWillAppear etc. are called.
//******************************************************************************
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


//******************************************************************************
//                              MARK: Save on Disk
//******************************************************************************
fileprivate extension RootViewController {
    
    var isPeriodicallySavingOnDisk: Bool {
        return saveOnDiskTimer != nil
    }
    
    func periodicallySaveOnDisk() {
        
        // Stop previous timers
        stopPeriodicallySavingOnDisk()
        
        // Set a periodical timer in a separate queue
        let timerQueue = DispatchQueue(label: "com.from101.VirtualTourist.saveOnDiskTimer", qos: .utility, attributes: .concurrent)
        saveOnDiskTimer = DispatchSource.makeTimerSource(queue: timerQueue)
        saveOnDiskTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(3), leeway: .seconds(1))
        
        // Save on disk
        saveOnDiskTimer?.setEventHandler(handler: { [weak self] in
            guard let s = self else { return }
            s.printOnMain("---> Timer called @ \(Date()) ")
            s.coreDataManager?.save()
            if s.shouldStopSavingOnDisk {
                s.stopPeriodicallySavingOnDisk()
            }
        })
        
        // Start the periodical timer
        saveOnDiskTimer?.resume()
        printOnMain("===> Timer initiated")
        
    }
    
    
    func stopPeriodicallySavingOnDisk() {
        saveOnDiskTimer?.cancel()
        saveOnDiskTimer = nil
        shouldStopSavingOnDisk = false
        printOnMain("===> Timer Stopped")
    }
    
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        coreDataManager?.save()
    }
    
    
    func printOnMain(_ str: String) {
        DispatchQueue.main.async {
            print(str)
        }
    }
    
}



