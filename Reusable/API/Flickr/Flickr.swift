//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Shobhit Gupta on 10/06/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit


public struct Flickr: SimpleAPI {
    static let scheme = Default.FlickrAPI.Scheme
    static let host = Default.FlickrAPI.Host
    static let path = Default.FlickrAPI.Path
}


fileprivate extension Flickr {
    
    static func defaultQueryParams() -> Parameters {
        return [
            Default.FlickrAPI.Param.Key.APIKey : Default.FlickrAPI.Param.Value.APIKey,
            Default.FlickrAPI.Param.Key.ResponseFormat : Default.FlickrAPI.Param.Value.ResponseFormat,
            Default.FlickrAPI.Param.Key.NoJSONCallback : Default.FlickrAPI.Param.Value.DisableJSONCallback
        ]
    }
    
    
    static func getJSON(fromURL url: URL, parameters: Parameters, completion: @escaping (_ success: Bool, _ json: JSON?, _ error: Error?) -> Void) {
        var queryParams = defaultQueryParams()
        queryParams += parameters
        
        Alamofire.request(url, method: .get, parameters: queryParams)
            .validate()
            .responseJSON { (response) in
                
                switch response.result {
                
                case .failure(let error):
                    completion(false, nil, error)
                    
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json, nil)
                }
        }
    }
    
    
}


public extension Flickr {
    
    public static func search(latitude: Double,
                              longitude: Double,
                              page: Int? = nil,
                              completion: @escaping (_ success: Bool, _ json: JSON?, _ error: Error?) -> Void) {
        
        guard let url = url() else {
            completion(false, nil, Error_.SimpleAPI.InvalidURL(sender: Flickr.self))
            return
        }
        
        var queryParams: [String : Any] = [
            Default.FlickrAPI.Param.Key.Extras : Default.FlickrAPI.Param.Value.MediumURL,
            Default.FlickrAPI.Param.Key.SafeSearch : Default.FlickrAPI.Param.Value.UseSafeSearch,
            Default.FlickrAPI.Param.Key.Method : Default.FlickrAPI.Method.SearchPhotos,
            Default.FlickrAPI.Param.Key.Latitude : latitude,
            Default.FlickrAPI.Param.Key.Longitude : longitude
        ]
        
        if let page = page, page > 0 {
            queryParams += [
                Default.FlickrAPI.Param.Key.Page : page
            ]
        }
        
        getJSON(fromURL: url, parameters: queryParams, completion: completion)
    
    }
    
    
    public static func randomSearch(latitude: Double,
                                    longitude: Double,
                                    completion: @escaping (_ success: Bool, _ json: JSON?, _ error: Error?) -> Void) {
        search(latitude: latitude, longitude: longitude) { (success, json, error) in
            guard success, let json = json else {
                completion(false, nil, error)
                return
            }
            
            // Parse JSON response: Example of expected JSON response from Flickr:
            // Case 1: Everything goes well.
            // {
            //     "photos": {
            //         "page": 7,
            //         "pages": 1428,
            //         "perpage": 3,
            //         "total": "4284",
            //         "photo": [...]
            //     },
            //     "stat": "ok"
            // }
            
            if let status = json[Default.FlickrAPI.Response.Key.Status].string,
                status.lowercased() == Default.FlickrAPI.Response.Value.OKStatus.lowercased(),
                let pages = json[Default.FlickrAPI.Response.Key.Photos][Default.FlickrAPI.Response.Key.Pages].int,
                let perPage = json[Default.FlickrAPI.Response.Key.Photos][Default.FlickrAPI.Response.Key.PerPage].int {
                
                    // [Flickr API Docs]: 
                    // - Flickr only returns first 4000 results at max.
                    // - Unlike standard photo queries, geo queries return 250 results per page.
                    let maxPages = Int(ceil(Double(Default.FlickrAPI.MaxNumPhotosInSearchResult / perPage)))
                    let randomPage = Int.random(lower: 1, upper: min(pages, maxPages) + 1)
                
                    search(latitude: latitude, longitude: longitude, page: randomPage, completion: completion)
                
            } else if let message = json[Default.FlickrAPI.Response.Key.Message].string {
                
                // Case 2: Some error
                // {
                //     "stat": "fail",
                //     "code": 999,
                //     "message": "Not a valid longitude"
                // }

                completion(false, nil, Error_.SimpleAPI.MethodFailed(method: Default.FlickrAPI.Method.SearchPhotos, message: message))
                return
            
            } else {
                completion(false, nil, Error_.SimpleAPI.MethodFailedWithUnexpectedJSONResponse(forMethod: Default.FlickrAPI.Method.SearchPhotos))
                return
                
            }
            
        }
    
    }
 
    
}


public extension Flickr {

    public static func getPhotoURLs(from json: JSON) -> [URL] {
        var urls = [URL]()
        
        // Parse JSON response: Example of expected JSON response from Flickr:
        // Case 1: Everything goes well.
        // {
        //     "photos": {
        //         "page": 7,
        //         "pages": 1428,
        //         "perpage": 3,
        //         "total": "4284",
        //         "photo": [
        //             {
        //                 "id": "35321531451",
        //                 "owner": "26984212@N03",
        //                 "secret": "32d5873bac",
        //                 "server": "4265",
        //                 "farm": 5,
        //                 "title": "Policeman, Shimla",
        //                 "ispublic": 1,
        //                 "isfriend": 0,
        //                 "isfamily": 0,
        //                 "url_m": "https://farm5.staticflickr.com/4265/35321531451_32d5873bac.jpg",
        //                 "height_m": "500",
        //                 "width_m": "334"
        //             },
        //             {
        //             	...
        //             }
        //         ]
        //     },
        //     "stat": "ok"
        // }

        if let photos = json[Default.FlickrAPI.Response.Key.Photos][Default.FlickrAPI.Response.Key.Photo].array {
            for photo in photos {
                if let url = photo[Default.FlickrAPI.Response.Key.MediumURL].url {
                    urls.append(url)
                }
            }
            
        }
        return urls
    }
    
    
}











