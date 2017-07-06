//
//  FileManager+Ease.swift
//  PitchPerfect
//
//  Created by Shobhit Gupta on 24/03/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation


public extension FileManager {
    
    public func appendFileExtension(_ fileExtension: String?, to name: String) -> String {
        return name + ((fileExtension != nil) ? ".\(fileExtension!)" : "")
    }
    
    
    public func uniqueFileName(withExtension fileExtension: String? = nil) -> String {
        let uniqueFileName = NSUUID().uuidString
        return appendFileExtension(fileExtension, to: uniqueFileName)
    }
    
    
    public func createPathForFile(_ name: String? = nil,
                                  withExtension fileExtension: String? = nil,
                                  relativeTo directory: SearchPathDirectory = Default.FileManager_.SearchPath.Directory,
                                  at subPath: String?,
                                  domainMask: SearchPathDomainMask = Default.FileManager_.SearchPath.DomainMask) throws -> URL {
        
        // Get a path to folder that will contain the file
        let folderURL = try createPathForFolder(at: subPath, relativeTo: directory, domainMask: domainMask)
        
        // Create a folder at folder path
        try createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
        
        // Create a file path for a file inside the above folder
        let fileURL: URL
        if let name = name {
            fileURL = folderURL.appendingPathComponent(appendFileExtension(fileExtension, to: name))
        } else {
            fileURL = folderURL.appendingPathComponent(uniqueFileName(withExtension: fileExtension))
        }
        
        return fileURL
        
    }
    
    
    public func createPathForFolder(at subPath: String?,
                                      relativeTo directory: SearchPathDirectory = Default.FileManager_.SearchPath.Directory,
                                      domainMask: SearchPathDomainMask = Default.FileManager_.SearchPath.DomainMask) throws -> URL {
        
        guard let pathForDirectory = NSSearchPathForDirectoriesInDomains(directory, domainMask, true).first else {
            throw Error_.FileManager_.pathNotFound(forDirectory: directory, inDomain: domainMask)
        }
        
        // Create folder path
        let folderURL: URL
        if let subPath = subPath {
            folderURL = URL(fileURLWithPath: pathForDirectory).appendingPathComponent(subPath, isDirectory: true)
        } else {
            folderURL = URL(fileURLWithPath: pathForDirectory)
        }
        
        return folderURL
        
    }
    
}


public extension Default.FileManager_ {
    
    enum SearchPath {
        static let Directory: FileManager.SearchPathDirectory = .documentDirectory
        static let DomainMask: FileManager.SearchPathDomainMask = .userDomainMask
    }
    
}



public extension Error_ {
    
    enum FileManager_: Error {
        case pathNotFound(forDirectory: FileManager.SearchPathDirectory, inDomain: FileManager.SearchPathDomainMask)
        
        var localizedDescription: String {
            // TODO: See if this error is being caught or not.
            var description = String(describing: self)
            switch self {
            case let .pathNotFound(directory, domain):
                description += "Path not found for \(directory) in \(domain)"
            }
            return description
        }
    }
    
}
