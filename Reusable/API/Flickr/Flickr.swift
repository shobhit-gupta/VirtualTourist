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
            
            if let pages = json["photos"]["pages"].int,
                let perPage = json["photos"]["perpage"].int {
                    // [Flickr API Docs]: 
                    // - Flickr only returns first 4000 results at max.
                    // - Unlike standard photo queries, geo queries return 250 results per page.
                    let maxPages = Int(ceil(Double(Default.FlickrAPI.MaxNumPhotosInSearchResult / perPage)))
                    let randomPage = Int.random(lower: 1, upper: min(pages, maxPages) + 1)
                
                    search(latitude: latitude, longitude: longitude, page: randomPage, completion: completion)
                
            } else {
                completion(false, nil, Error_.SimpleAPI.MethodFailedWithUnexpectedJSONResponse(forMethod: Default.FlickrAPI.Method.SearchPhotos))
                return
                
            }
            
        }
    
    }
    
}
