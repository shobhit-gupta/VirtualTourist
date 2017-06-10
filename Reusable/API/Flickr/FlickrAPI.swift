//
//  FlickrAPI.swift
//  OnTheMap
//
//  Created by Shobhit Gupta on 24/05/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation


struct FlickrAPI: SimpleAPI {    
    static let scheme = Default.FlickrAPI.Scheme
    static let host = Default.FlickrAPI.Host
    static let path = Default.FlickrAPI.Path
}


public extension Default {
    enum FlickrAPI {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
        
        enum Param {
            
            enum Key {
                static let Method = "method"
                static let APIKey = "api_key"
                static let GalleryId = "gallery_id"
                static let Extras = "extras"
                static let Format = "format"
                static let NoJSONCallback = "nojsoncallback"
            }
            
            enum Value {
                static let APIKey = "YOUR-API-KEY"
                static let ResponseFormat = "json"
                static let DisableJSONCallback = "1" // 1 means "yes"
                
                static let GalleryId = "5704-72157622566655097"
                static let MediumURL = "url_m"
                
                enum Method {
                    static let GalleryPhotos = "flickr.galleries.getPhotos"
                    static let SearchPhotos = "flickr.photos.search"
                }
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
