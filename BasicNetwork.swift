//
//  BasicNetwork.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation




public class BasicNetwork {
    
    public enum NetworkMode {
        case localhost,development,production,placeholder
        
        var server:String {
            get {
                switch self {
                case .localhost:
                    return "http://0.0.0.0:8080"
                case .development:
                    return "http://theisegeberg.com:8080"
                case .production:
                    return "http://theisegeberg.com:8081"
                case .placeholder:
                    return "https://jsonplaceholder.typicode.com"
                }
            }
        }
    }
    
    
    public enum HTTPMethod:CustomStringConvertible {
        
        public var description: String {
            switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            }
        }
        
        case get,post
        
    }
    
    public enum BasicNetworkError:Error {
        case couldNotFormatFormatURL(String)
        case couldNotSerializeJSON(String)
        case noData
    }
    
    
    public enum JSONResponse {
        case error(Error)
        case success([String:Any])
    }
    
    public typealias JSONCompletionHandler = (JSONResponse) -> ()
    
    public var mode:NetworkMode = .placeholder
    
    public func request(endPoint:String,parameters:[String:Any]?,method:HTTPMethod,completionHandler:JSONCompletionHandler? = nil) {
        
        guard let url = URL(string:"\(self.mode.server)\(endPoint)") else {
            completionHandler?(JSONResponse.error(BasicNetworkError.couldNotFormatFormatURL("\(self.mode.server)\(endPoint)")))
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 20.0)
        
        request.httpMethod = method.description
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            do {
                
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                completionHandler?(JSONResponse.error(error))
            }
        }
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data,response,error in
            print("REQUEST")
            print(request)
            print("RESPONSE")
            print(response)
            guard error == nil else {
                completionHandler?(JSONResponse.error(error!))
                return
            }
            
            guard let data = data else {
                completionHandler?(JSONResponse.error(BasicNetworkError.noData))
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                    
                    guard let rawResponse = String(data: data, encoding: .utf8) else {
                        completionHandler?(JSONResponse.error(BasicNetworkError.couldNotSerializeJSON("Warning:Unable to decode data to string, this is a placeholder")))
                        return
                    }
                    completionHandler?(JSONResponse.error(BasicNetworkError.couldNotSerializeJSON(rawResponse)))
                    return
                }
                
                completionHandler?(JSONResponse.success(json))
                
            } catch let error {
                completionHandler?(JSONResponse.error(error))
            }
        }
        task.resume()
    
    }
    
    
}
