//
//  BasicNetwork.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public typealias CompletionHandler = (Response) -> Void

public class BasicNetwork {

    public var timeOut: TimeInterval = 5
    public var mockDelay: Double = 0.5
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    public var generateReports: Bool = true

    public init() {

    }

    public func mockRequest(server: String, endPoint: EndPoint, parameters: [String:Any]?, method: HTTPMethod, completionHandler: @escaping CompletionHandler, mockData: Data) {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.mockDelay) {
            completionHandler(.success(mockData, report: nil))
        }
    }

    public func mockRequest(server: String, endPoint: EndPoint, parameters: [String:Any]?, method: HTTPMethod, completionHandler: @escaping CompletionHandler, mockJson: String) {

        if let mockData = mockJson.data(using: .utf8) {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.mockDelay) {
                completionHandler(.success(mockData, report: nil))
            }
            return
        }
        completionHandler(.error(.dataMissingError, report: nil))
    }

    public func request(server: String, endPoint: EndPoint, parameters: [String:Any]?, method: HTTPMethod, completionHandler: CompletionHandler? = nil) {

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
                    request.url = url.withQueryStringParameters(parameters: parameters)

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

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

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
