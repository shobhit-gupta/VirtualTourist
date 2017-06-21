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
    private let modelName: String
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        guard case .withPrivatePersistentQueue = self.type else {
            fatalError(Error_.General.UnexpectedCurrentState(state: "\(self.type)").localizedDescription)
        }
        let pmoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        pmoc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return pmoc
    }()
    
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError(Error_.CoreData.DataModelMissing(modelName: self.modelName).localizedDescription)
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError(Error_.CoreData.CorruptDataModel(modelName: self.modelName).localizedDescription)
        }
        return mom
    }()
    
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Create sqlite persistent store
        guard let url = try? FileManager.default.createPathForFile(self.modelName,
                                                                   withExtension: "sqlite",
                                                                   relativeTo: .documentDirectory,
                                                                   at: "CoreData") else {
            fatalError("Couldn't create persistent store file")
        }

        let psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url)
        } catch {
            fatalError("Unable to load persistent store")
        }
        
        return psc
    }()
    
    
    init(modelName: String, ofType type: CoreDataManagerType) {
        self.modelName = modelName
        self.type = type
    }
    
    
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
    
    
}


public extension Error_ {

    enum CoreData: Error {
        case DataModelMissing(modelName: String)
        case CorruptDataModel(modelName: String)
        
        var localizedDescription: String {
            let description : String
            switch self {
                
            case .DataModelMissing(let modelName):
                description = "Couldn't find data model document: \(modelName).xcdatamodeld"
                
            case .CorruptDataModel(let modelName):
                description = "Couldn't load data model from \(modelName).xcdatamodeld"
                
            }
            
            return description
        }
    
    }
    
}






