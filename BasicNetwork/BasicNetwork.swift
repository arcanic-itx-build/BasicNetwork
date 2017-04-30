//
//  BasicNetwork.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation


extension URL {
    
    public func withQueryStringParameters(parameters:[String:Any]) -> URL {
        
        let queryString = parameters.flatMap { (keyValue) -> String? in
            return "\(keyValue.key)=\(keyValue.value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }.joined(separator: "&")
        
        return URL(string: "\(self.absoluteString)?\(queryString)")!
    }
    
}


public class BasicNetwork {
    
    public static let defaultCompletionHandler:CompletionHandler = { (response) in
        switch response {
        case .error(let error, let report):
            print("Error")
            print(error)
            print(report.prettyPrint())
        case .success(let data,let report):
            print("Success")
            print(String(data: data, encoding: .utf8) ?? "Can't decode data: \(data)")
            print(report.prettyPrint())
        }
    }


    public enum Response {
        case error(Error,report:RequestReport)
        case success(Data,report:RequestReport)
    }

    public typealias CompletionHandler = (Response) -> ()
    
    public var server:String = "http://0.0.0.0:8080"
    public var timeOut:TimeInterval = 5
    public var cachePolicy:URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    
    public init() {
        
    }

    public func request(endPoint:EndPoint,parameters:[String:Any]?,method:HTTPMethod,completionHandler:CompletionHandler? = nil) {
        
        var report = RequestReport()
        
        guard let url = URL(string:"\(self.server)/\(endPoint.description)") else {
            completionHandler?(Response.error(BasicNetworkError.urlCreationError("\(self.server)\(endPoint)"),report: report))
            return
        }
        
        
        var request = URLRequest(url: url, cachePolicy: self.cachePolicy, timeoutInterval: self.timeOut)
        
        request.httpMethod = method.description
        
        if let parameters = parameters {
            do {
                switch method {
                case .get:
                    request.url = request.url?.withQueryStringParameters(parameters: parameters)
                    
                case .post:
                    let requestBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = requestBody
                    report.requestBody = String(data: requestBody, encoding: .utf8)
                }
                
            } catch let error {
                completionHandler?(Response.error(error,report: report))
            }
        }
        
        report.url = request.url
        report.method = method
        
        
        report.state = .requestSent
        
        let task = URLSession.shared.dataTask(with: request) { data,response,error in

            report.state = .responseReceived
            report.requestHeaders = request.allHTTPHeaderFields
            
            guard error == nil else {
                completionHandler?(Response.error(error!,report: report))
                return
            }
            
            guard let data = data else {
                completionHandler?(Response.error(BasicNetworkError.dataMissingError,report: report))
                return
            }
            
            report.responseBody = String(data:data, encoding:.utf8) ?? "Unable to decode body"
            
            if let httpResponse = response as? HTTPURLResponse {
                
                report.statusCode = httpResponse.statusCode
                report.responseHeaders = httpResponse.allHeaderFields
                
                if (httpResponse.statusCode >= 400) {
                    completionHandler?(Response.error(BasicNetworkError.httpError(statusCode: httpResponse.statusCode, description: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)),report: report))
                    return
                }
            }
            
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                report.responseBody = rawResponse
            }
            
            DispatchQueue.main.async {
                completionHandler?(Response.success(data,report: report))
            }
            
        }
        task.resume()
    
    }
    
    
}
