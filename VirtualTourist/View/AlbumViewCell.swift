//
//  AlbumViewCell.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 07/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit
import M13ProgressSuite


class AlbumViewCell: UICollectionViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: M13ProgressViewRing!
    
    
    // MARK: Public variables and types
    public var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            if let image = newValue {
                currentState = .completed(withImage: image)
            } else {
                currentState = .indeterminate
            }
        }
    }
    
    public var progress: Double? {
        didSet {
            if case .completed = currentState {
                return
            }
            currentState = progress != nil ? .progressing(fractionCompleted: progress!) : .indeterminate
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? selectionBorder : Default.GridViewCell.Unselected.Border.Width
        }
    }

    
    // MARK: Private variables and types
    fileprivate enum State {
        case indeterminate
        case progressing(fractionCompleted: Double)
        case completed(withImage: UIImage)
    }
    
    fileprivate var currentState: State = .indeterminate {
        didSet {
            updateView()
        }
    }
    
    fileprivate let selectionBorder: CGFloat = Default.GridViewCell.Selected.Border.Width
    
    
    // MARK: Standard callbacks
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    
    override func prepareForReuse() {
        setupView()
    }
    
    
}


//******************************************************************************
//                              MARK: Setup
//******************************************************************************
extension AlbumViewCell {
    
    fileprivate func setupView() {
        setupProperties()
        setupImageView()
        setupProgressView()
    }
    
    
    fileprivate func setupImageView() {
        imageView.layer.borderColor = Default.GridViewCell.Selected.Border.Color.cgColor
    }
    
    
    fileprivate func setupProperties() {
        isSelected = false
        backgroundColor = Default.GridViewCell.BackgroundColor
        currentState = .indeterminate
    }
    
    
    fileprivate func setupProgressView() {
        
    }
    
    
    fileprivate func updateView() {
        switch currentState {
        case .indeterminate:
            imageView.image = nil
            progressView.isHidden = false
            progressView.indeterminate = true
            progressView.showPercentage = false
            
        case .progressing(let fraction):
            imageView.image = nil
            progressView.isHidden = false
            progressView.indeterminate = false
            progressView.showPercentage = true
            progressView.setProgress(CGFloat(fraction), animated: true)
            
        case .completed(let image):
            imageView.image = image
            progressView.indeterminate = false
            progressView.showPercentage = false
            progressView.isHidden = true
        
        }
    }
    
    
}
