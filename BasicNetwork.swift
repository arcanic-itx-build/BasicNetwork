//
//  BasicNetwork.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation



public class BasicNetwork {
    
    public static let defaultCompletionHandler:JSONCompletionHandler = { (response) in
        switch response {
        case .error(let error, let report):
            print("ERROR")
            print(error)
            print(report.prettyPrint())
        case .success(let json,let report):
            print("Success")
            print(json)
            print(report.prettyPrint())
        }
    }
    
    public struct EndPoint:CustomStringConvertible {
        private let parts:[String]
        
        public var description: String {
            get {
                return parts.joined(separator: "/")
            }
        }
        
        init(_ part:String...) {
            parts = part
        }
    }
    
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
        case httpError(statusCode:Int,description:String)
        case couldNotFormatFormatURL(String)
        case couldNotSerializeJSON(String)
        case noData
    }
    
    
    public enum JSONResponse {
        case error(Error,report:RequestReport)
        case success([String:Any],report:RequestReport)
    }
    
    public struct RequestReport {
        
        public enum State {
            case created,requestSent,responseReceived,responseDecoded
        }
        
        public var url:URL?
        public var state:State = .created
        public var method:HTTPMethod?
        public var statusCode:Int?
        public var requestHeaders:[String:String]?
        public var responseHeaders:[AnyHashable:Any]?
        public var responseBody:String?
        public var requestBody:String?
        
        public func prettyPrint() -> String {
            return "===> Request report [\(statusCode ?? -1)] =========||\n\(url?.absoluteString ?? "?") (\(method?.description ?? "?"))\n" +
            "\(requestBody ?? "[No request body]")\n" +
            "\(responseBody ?? "[No response body]")\n" +
            "=========\n"
        }
    }
    
    
    public typealias JSONCompletionHandler = (JSONResponse) -> ()
    
    public var mode:NetworkMode = .placeholder
    public var timeOut:TimeInterval = 5
    public var cachePolicy:URLRequest.CachePolicy = .reloadRevalidatingCacheData
    
    public func request(endPoint:EndPoint,parameters:[String:Any]?,method:HTTPMethod,completionHandler:JSONCompletionHandler? = nil) {
        
        var report = RequestReport()
        
        guard let url = URL(string:"\(self.mode.server)/\(endPoint.description)") else {
            completionHandler?(JSONResponse.error(BasicNetworkError.couldNotFormatFormatURL("\(self.mode.server)\(endPoint)"),report: report))
            return
        }
        
        report.url = url
        report.method = method
        
        var request = URLRequest(url: url, cachePolicy: self.cachePolicy, timeoutInterval: self.timeOut)
        
        request.httpMethod = method.description
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            do {
                
                let requestBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                
                request.httpBody = requestBody
    
                report.requestBody = String(data: requestBody, encoding: .utf8)
                
            } catch let error {
                completionHandler?(JSONResponse.error(error,report: report))
            }
        }
        
        
        report.state = .requestSent
        
        let task = URLSession.shared.dataTask(with: request) { data,response,error in

            report.state = .responseReceived
            report.requestHeaders = request.allHTTPHeaderFields
            
            guard error == nil else {
                completionHandler?(JSONResponse.error(error!,report: report))
                return
            }
            
            guard let data = data else {
                completionHandler?(JSONResponse.error(BasicNetworkError.noData,report: report))
                return
            }
            
            report.responseBody = String(data:data, encoding:.utf8) ?? "Unable to decode body"
            
            if let httpResponse = response as? HTTPURLResponse {
                
                report.statusCode = httpResponse.statusCode
                report.responseHeaders = httpResponse.allHeaderFields
                
                if (httpResponse.statusCode >= 400) {
                    completionHandler?(JSONResponse.error(BasicNetworkError.httpError(statusCode: httpResponse.statusCode, description: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)),report: report))
                    return
                }
            }
            
            
            
            do {
                
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                    
                    let rawResponse = String(data: data, encoding: .utf8) ?? "Warning: couldn't decode response from data to utf8"
                    completionHandler?(JSONResponse.error(BasicNetworkError.couldNotSerializeJSON(rawResponse),report: report))
                    return
                }
                
                
                
                completionHandler?(JSONResponse.success(json,report: report))
                
            } catch let error {
                completionHandler?(JSONResponse.error(error,report: report))
            }
        }
        task.resume()
    
    }
    
    
}
