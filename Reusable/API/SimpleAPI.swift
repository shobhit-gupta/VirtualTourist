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
    static func url(from params: [String : Any]?, withPathExtension pathExtension: String?) -> URL?
}


extension SimpleAPI {
    
    static func url(from params: [String : Any]? = nil, withPathExtension pathExtension: String? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        if let pathExtension = pathExtension,
            let url = components.url {
            components.path = url.appendingPathComponent(pathExtension).path
        }
        
        if let params = params, params.count > 0 {
            components.queryItems = [URLQueryItem]()
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }	
        }
        
        return components.url
    }
    
}


public extension Error_ {
    
    enum SimpleAPI: Error {
        case InvalidURL(sender: Any.Type)
        case MethodFailed(method: String, message: String)
        case MethodFailedWithUnexpectedJSONResponse(forMethod: String)
        
        var localizedDescription: String {
            let description : String
            switch self {
                
            case .InvalidURL(let sender):
                description = "Couldn't construct url for: \(sender)"
                
            case let .MethodFailed(method, message):
                description = "\(method) method failed: \(message)"
                
            case .MethodFailedWithUnexpectedJSONResponse(let method):
                description = "\(method) method failed: Unexpected JSON Response"
                
            }
            
            return description
        }
        
    }
    
}
