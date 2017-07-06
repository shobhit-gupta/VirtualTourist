//
//  NSManagedContext+Ease.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 21/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import CoreData


public extension NSManagedObjectContext {
    
    public func saveChanges() {
        if hasChanges {
            do {
                try save()
            } catch {
                print((error as NSError).info())
            }
        }
    }
    
}
