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
    
    public var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            progressView.isHidden = newValue != nil ? true : false
            progressView.indeterminate = true
        }
    }
    
    fileprivate let selectionBorder: CGFloat = Default.GridViewCell.Selected.Border.Width
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? selectionBorder : Default.GridViewCell.Unselected.Border.Width
        }
    }
    
    
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
        image = nil
        imageView.layer.borderColor = Default.GridViewCell.Selected.Border.Color.cgColor
    }
    
    
    fileprivate func setupProperties() {
        isSelected = false
        backgroundColor = Default.GridViewCell.BackgroundColor
    }
    
    
    fileprivate func setupProgressView() {
        progressView.isHidden = false
        progressView.indeterminate = true
    }
    
}
