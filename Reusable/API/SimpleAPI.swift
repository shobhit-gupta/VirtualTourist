//
//  SimpleAPI.swift
//  OnTheMap
//
//  Created by Shobhit Gupta on 23/05/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation

protocol SimpleAPI {
    static var scheme: String { get }
    static var host: String { get }
    static var path: String { get }
    static func url(from params: [String : Any], withPathExtension pathExtension: String?) -> URL?
}


extension SimpleAPI {
    
    static func url(from params: [String : Any], withPathExtension pathExtension: String? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        if let pathExtension = pathExtension,
            let url = components.url {
            components.path = url.appendingPathComponent(pathExtension).path
        }
        
        if params.count > 0 {
            components.queryItems = [URLQueryItem]()
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }	
        }
        
        return components.url
    }
    
}
