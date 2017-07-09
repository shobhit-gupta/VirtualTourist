//
//  HeaderCollectionReusableView.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 07/07/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import UIKit
import MapKit


class HeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var mapView: MKMapView!
    
    public func showCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: Default.GridView.Header.Span.DeltaLatitude,
                                    longitudeDelta: Default.GridView.Header.Span.DeltaLongitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}
