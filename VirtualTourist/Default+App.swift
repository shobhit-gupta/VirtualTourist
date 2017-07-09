//
//  Default+App.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 20/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
import UIKit


public extension Default {
    
    enum DownloadQueue {
        static let MaxConcurrentOperations = 3
    }
    
    
    enum FileName {
        static let DataModel = "Model"
        static let MainStoryboard = "Main"
    }
    
    
    enum General {
        static let iOSMinWidth: CGFloat = 320.0
    }
    
    
    enum GridView {
        static let NumCellsOnSmallestSide = 2   // Say for an old iPhone in portrait mode
        
        enum Header {
            static let ReuseId = "AlbumViewMapHeader"
            static let Height: CGFloat = 100.0
            
            enum Span {
                static let DeltaLatitude: Double = 0.1
                static let DeltaLongitude: Double = 1.0
            }
        }
    }
    
    
    enum GridViewCell {
        static let ReuseId = "AlbumViewCell"
        static let BackgroundColor: UIColor = UIColor.clear
        static let CornerRadius: CGFloat = 4.0
        
        enum Selected {
            static let OnReuse = false
            
            enum Border {
                static let Width: CGFloat = 2.0
                static let Color: UIColor = ArtKit.primaryColor
            }
            
            enum Overlay {
                static let Color: UIColor = UIColor.white.withAlphaComponent(1.0)
                static let Alpha: CGFloat = 0.5
            }
            
        }
        
        enum Unselected {
            enum Border {
                static let Width: CGFloat = 0.0
            }
        }
        
        enum AspectRatio {
            static let TooWide: CGFloat = 2.0
            static let Square: CGFloat = 1.0
            static let TooNarrow: CGFloat = 0.5
        }
        
    }
    
    
    enum LongPress {
        static let NumberOfTapsRequired = 1
        static let MinimumPressDuration: CFTimeInterval = 0.5
    }
    
    
    enum Photo {
        enum KeyPath {
            static let Url = "url"
            static let Pin = "pin"
        }
    }
    
    
    enum Pin {
        enum KeyPath {
            static let Latitude = "latitude"
            static let Longitude = "longitude"
            static let Location = "location"
        }
    }
    
    
    enum ProgressView {
        enum Color {
            static let Primary = ArtKit.highlightOfPrimaryColor
            static let Secondary = ArtKit.shadowOfSecondaryColor
        }
    }
    
    
    enum SaveOnDiskTimer {
        static let Interval: DispatchTimeInterval = .seconds(3)
        static let Leeway: DispatchTimeInterval = .seconds(1)
    }
    
    enum StoryboardId {
        static let TravelLocationsMapViewVC = "TravelLocationsMapViewController"
        static let AlbumVC = "AlbumViewController"
    }
    
    
}


public extension Default.DispatchQueue_.Label {
    static let SaveOnDiskTimerQueue = Default.DispatchQueue_.Label.Main + "." + "SaveOnDiskTimer"
}


public extension Default.AsynchronousOperation {
    
    enum GetPhotoURLsForPin {
        static let QueuePriority: Operation.QueuePriority = .veryHigh
        static let NoURLsFoundMessage = "0 photos found"
    }
    
    enum DownloadPhoto {
        static let DownloadFractionUpdateStep: Float = 0.1 // 0.1 => 10%
        static let MaxRetries = 4
        static let QueuePriority: Operation.QueuePriority = .normal
        static let QueuePriorityInBackground: Operation.QueuePriority = .low
    }
    
}
