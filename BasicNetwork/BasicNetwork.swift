//
//  BasicNetwork.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public class BasicNetwork {

    public static let defaultCompletionHandler: CompletionHandler = {
        (response) in
        switch response {
        case .error(let error, let report):
            print("Error")
            print(error)
            print(report?.prettyPrint() ?? "No report generated")
        case .success(let data, let report):
            print("Success")
            print(String(data: data, encoding: .utf8) ?? "Can't decode data: \(data)")
            print(report?.prettyPrint() ?? "No report generated")
        }
    }

    public enum Response {
        case error(NetworkError, report:RequestReport?)
        case success(Data, report:RequestReport?)
    }

    public typealias CompletionHandler = (Response) -> Void

    public var timeOut: TimeInterval = 5
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    public var generateReports: Bool = true

    public init() {

    }

    public func request(server:String, endPoint: EndPoint, parameters: [String:Any]?, method: HTTPMethod, completionHandler: CompletionHandler? = nil) {

        var report: RequestReport?

        if self.generateReports {
            report = RequestReport()
        }

        guard let url = URL(string:"\(server)/\(endPoint.description)") else {
            completionHandler?(Response.error(.urlCreationError("\(server)/\(endPoint)"), report: report))
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
                    report?.requestBody = String(data: requestBody, encoding: .utf8)?.jsonIndented()
                }

            } catch let error {
                completionHandler?(Response.error(.underlyingError(error), report: report))
            }
        }

        report?.url = request.url
        report?.method = method

        report?.state = .requestSent

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            report?.state = .responseReceived
            report?.requestHeaders = request.allHTTPHeaderFields

            guard error == nil else {
                if let error = error {
                    completionHandler?(Response.error(.underlyingError(error), report: report))
                }
                return
            }

            guard let data = data else {
                completionHandler?(Response.error(.dataMissingError, report: report))
                return
            }

            report?.responseBody = String(data:data, encoding:.utf8)?.jsonIndented() ?? "Unable to decode body"

            if let httpResponse = response as? HTTPURLResponse {

                report?.statusCode = httpResponse.statusCode
                report?.responseHeaders = httpResponse.allHeaderFields

                if (httpResponse.statusCode >= 400) {
                    completionHandler?(Response.error(.httpError(statusCode: httpResponse.statusCode, description: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)), report: report))
                    return
                }
            }

            DispatchQueue.main.async {
                completionHandler?(Response.success(data, report: report))
            }

        }
        task.resume()

    }

}
