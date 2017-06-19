//
//  Default+Flickr.swift
//  OnTheMap
//
//  Created by Shobhit Gupta on 24/05/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation


public extension Default {
    enum FlickrAPI {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
        static let MaxNumPhotosInSearchResult = 4000
        
        enum Method {
            static let GalleryPhotos = "flickr.galleries.getPhotos"
            static let SearchPhotos = "flickr.photos.search"
        }

        enum Param {
            
            enum Key {
                static let Method = "method"
                static let APIKey = "api_key"
                static let GalleryId = "gallery_id"
                static let Extras = "extras"
                static let ResponseFormat = "format"
                static let NoJSONCallback = "nojsoncallback"
                static let SafeSearch = "safe_search"
                static let Page = "page"
                static let Latitude = "lat"
                static let Longitude = "lon"
            }
            
            enum Value {
                static let APIKey = "ad1e175cc4263b5cb30b134cbc8c77f2"
                static let ResponseFormat = "json"
                static let DisableJSONCallback = 1 // 1 means "yes"
                static let UseSafeSearch = 0
                static let GalleryId = "SOME-GALLERY-ID"
                static let MediumURL = "url_m"
            }
            
        }
        
        
        enum Response {
            
            enum Key {
                static let Status = "stat"
                static let Photos = "photos"
                static let Photo = "photo"
                static let Title = "title"
                static let MediumURL = "url_m"
            }
            
            enum Value {
                static let OKStatus = "ok"
            }
            
        }
        
    }
}
