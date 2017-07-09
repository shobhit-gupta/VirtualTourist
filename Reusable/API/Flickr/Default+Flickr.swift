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
        static let Host = "api.flickr.com"
        static let MaxNumPhotosInSearchResult = 4000
        static let Path = "/services/rest"
        static let Scheme = "https"
        
        enum Method {
            static let GalleryPhotos = "flickr.galleries.getPhotos"
            static let SearchPhotos = "flickr.photos.search"
        }

        enum Param {
            
            enum Key {
                static let APIKey = "api_key"
                static let Extras = "extras"
                static let GalleryId = "gallery_id"
                static let Latitude = "lat"
                static let Longitude = "lon"
                static let Method = "method"
                static let NoJSONCallback = "nojsoncallback"
                static let Page = "page"
                static let ResponseFormat = "format"
                static let SafeSearch = "safe_search"
            }
            
            enum Value {
                static let APIKey = "ad1e175cc4263b5cb30b134cbc8c77f2"
                static let DisableJSONCallback = 1 // 1 means "yes"
                static let GalleryId = "SOME-GALLERY-ID"
                static let MediumURL = "url_m"
                static let ResponseFormat = "json"
                static let UseSafeSearch = 0
            }
            
        }
        
        
        enum Response {
            
            enum Key {
                static let Height = "height_m"
                static let MediumURL = "url_m"
                static let Message = "message"
                static let Pages = "pages"
                static let PerPage = "perpage"
                static let Photo = "photo"
                static let Photos = "photos"
                static let Status = "stat"
                static let Title = "title"
                static let Width = "width_m"
            }
            
            enum Value {
                static let FailStatus = "fail"
                static let OKStatus = "ok"
            }
            
        }
        
    }
}
