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
    
    enum FileName {
        static let DataModel = "Model"
        static let MainStoryboard = "Main"
    }
    
    
    enum General {
        static let iOSMinWidth: CGFloat = 320.0
    }
    
    
    enum GridView {
        static let NumCellsOnSmallestSide = 2   // Say for an old iPhone in portrait mode
    }
    
    
    enum GridViewCell {
        static let ReusableCellId = "AlbumViewCell"
        static let BackgroundColor: UIColor = UIColor.clear
        static let CornerRadius: CGFloat = 4.0
        
        enum Selected {
            static let OnReuse = false
            
            enum Border {
                static let Width: CGFloat = 2.0
                static let Color: UIColor = UIColor.black //ArtKit.primaryColor
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
    
}
