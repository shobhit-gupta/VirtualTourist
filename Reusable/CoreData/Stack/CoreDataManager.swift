//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 19/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import CoreData


public enum CoreDataManagerType {
    // -------------------------------
    //  Main Managed Object Context
    //
    //             ⬇︎
    //
    // Persistent Store Coordinator
    //
    //             ⬇︎
    //
    //      Persistent Store
    // -------------------------------
    case simple
    
    
    // ---------------------------------------------------------------
    // Child Managed Object Context     Child Managed Object Context
    //
    //                     ⬇︎              ⬇︎
    //
    //                Main Managed Object Context
    //
    //                             ⬇︎
    //
    //              Private Managed Object Context
    //
    //                             ⬇︎
    //
    //               Persistent Store Coordinator
    //
    //                             ⬇︎
    //
    //                     Persistent Store
    // ---------------------------------------------------------------
    case withPrivatePersistentQueue
    
}


public final class CoreDataManager {

    // MARK: Public variables and types
    typealias CoreDataMangerCompletion = () -> Void
    public let type: CoreDataManagerType
    
    public private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let mmoc: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        switch self.type {
        case .simple:
            mmoc.persistentStoreCoordinator = self.persistentStoreCoordinator
        case .withPrivatePersistentQueue:
            mmoc.parent = self.privateManagedObjectContext
        }
        return mmoc
    }()
    
    
    // MARK: Private variables and types
    fileprivate let modelName: String
    fileprivate let completion: CoreDataMangerCompletion
    
    fileprivate lazy var privateManagedObjectContext: NSManagedObjectContext = {
        guard case .withPrivatePersistentQueue = self.type else {
            fatalError(Error_.General.UnexpectedCurrentState(state: "\(self.type)").localizedDescription)
        }
        let pmoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        pmoc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return pmoc
    }()
    
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName,
                                             withExtension: Default.CoreData.ManagedObjectModel.DocumentFileExtension) else {
            fatalError(Error_.CoreData.DataModelMissing(modelName: self.modelName).localizedDescription)
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError(Error_.CoreData.CorruptDataModel(modelName: self.modelName).localizedDescription)
        }
        return mom
    }()
    
    
    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        return psc
    }()
    
    
    init(modelName: String, ofType type: CoreDataManagerType, completion: @escaping CoreDataMangerCompletion) {
        self.modelName = modelName
        self.type = type
        self.completion = completion
        setupCoreDataStack()
    }
    
    
}


public extension CoreDataManager {
    
    public func save() {
        switch type {
        case .simple:
            mainManagedObjectContext.saveChanges()
            
        case .withPrivatePersistentQueue:
            mainManagedObjectContext.performAndWait {
                self.mainManagedObjectContext.saveChanges()
            }
            privateManagedObjectContext.perform {
                self.privateManagedObjectContext.saveChanges()
            }
            
        }
        
    }
    
    
    public func privateChildManagedObjectContext() -> NSManagedObjectContext {
        let pcmoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        pcmoc.parent = mainManagedObjectContext
        return pcmoc
    }

    
}



public extension CoreDataManager {

    fileprivate func setupCoreDataStack() {
        // Ensure Core Data stack is set up.
        let _ = mainManagedObjectContext.persistentStoreCoordinator
        
        DispatchQueue.global().async {
            // Add persistent store
            self.addPersistentStore()
            
            // Invoke completion on main queue
            DispatchQueue.main.async(execute: self.completion)
        }
    }
    
    
    private func addPersistentStore() {
        // Create sqlite persistent store
        guard let url = try? FileManager.default.createPathForFile(self.modelName,
                                                                   withExtension: Default.CoreData.PersistentStore.FileExtension,
                                                                   relativeTo: Default.CoreData.PersistentStore.SearchPathDirectory,
                                                                   at: Default.CoreData.PersistentStore.Subdirectory) else {
            fatalError(Error_.CoreData.PersistentStoreCreationFailed.localizedDescription)
        }
        
        let options = [NSMigratePersistentStoresAutomaticallyOption : Default.CoreData.PersistentStore.Coordinator.ShouldAutomaticallyMigrate,
                       NSInferMappingModelAutomaticallyOption : Default.CoreData.PersistentStore.Coordinator.ShouldAutomaticallyInferMappingModel]
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: Default.CoreData.PersistentStore.Kind,
                                                              configurationName: nil,
                                                              at: url,
                                                              options: options)
        } catch {
            fatalError(Error_.CoreData.PersistentStoreLoadingFailed.localizedDescription)
        }
        
    }

    
}


public extension Default {
    
    enum CoreData {
        enum ManagedObjectModel {
            static let DocumentFileExtension = "momd"
        }
        
        enum PersistentStore {
            static let FileExtension = "sqlite"
            static let SearchPathDirectory: FileManager.SearchPathDirectory = .documentDirectory
            static let Subdirectory = "CoreData"
            static let Kind = NSSQLiteStoreType
            
            enum Coordinator {
                static let ShouldAutomaticallyMigrate = true
                static let ShouldAutomaticallyInferMappingModel = true
            }
        }
    }
    
}


public extension Error_ {

    enum CoreData: Error {
        case DataModelMissing(modelName: String)
        case CorruptDataModel(modelName: String)
        case PersistentStoreCreationFailed
        case PersistentStoreLoadingFailed
        
        var localizedDescription: String {
            let description : String
            switch self {
                
            case .DataModelMissing(let modelName):
                description = "Couldn't find data model document: \(modelName).xcdatamodeld"
                
            case .CorruptDataModel(let modelName):
                description = "Couldn't load data model from \(modelName).xcdatamodeld"
                
            case .PersistentStoreCreationFailed:
                description = "Couldn't create persistent store file"
                
            case .PersistentStoreLoadingFailed:
                description = "Unable to load persistent store"
                
            }
            
            return description
        }
    
    }
    
}






