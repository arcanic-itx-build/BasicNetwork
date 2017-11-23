//
//  BasicNetwork.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public typealias CompletionHandler = (Response) -> Void

open class BasicNetwork {

    public var timeOut: TimeInterval = 120
    public var mockDelay: Double = 0.5
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    public var generateReports: Bool = true
    public var persistentHeaders = [(field:String, value:String)]()

    private var session:URLSession

    public init() {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 20
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    public func urlRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: self.cachePolicy, timeoutInterval: self.timeOut)
        for header in self.persistentHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        return request
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
        completionHandler(.error(NetworkError.dataMissingError, report: nil))
    }

    public func createRequest(server: String, endPoint: EndPoint, parameters: [String:Any]?, method: HTTPMethod) throws -> (URLRequest) {
        guard let url = URL(string:"\(server)/\(endPoint.description)") else {
            throw NetworkError.urlCreationError("\(server)/\(endPoint)")
        }

        var request = self.urlRequest(url: url)

        request.httpMethod = method.description

        if let parameters = parameters {
            switch method {
            case .get:
                request.url = url.withQueryStringParameters(parameters: parameters)
            case .post(let postMethod):
                switch postMethod {
                case .json:
                    let requestBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = requestBody
                    request.addValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
                case .urlencoded:
                    let requestBody = URL.encodedParameters(parameters: parameters)
                    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpBody = requestBody.data(using: .utf8)
                    request.addValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
                }

            }
        }

        return request
    }

    public func createTask(request: URLRequest, completionHandler: CompletionHandler? = nil) -> URLSessionDataTask {

        var report: RequestReport?

        if self.generateReports {
            report = RequestReport()
        }

        if let body = request.httpBody {
            report?.requestBody = String(data: body, encoding: .utf8)?.jsonIndented()
        }
        report?.url = request.url
        report?.method = request.httpMethod

        let task = self.session.dataTask(with: request) { data, response, error in

            report?.requestHeaders = request.allHTTPHeaderFields

            guard error == nil else {
                if let error = error {
                    DispatchQueue.main.async {
                        completionHandler?(Response.error(error, report: report))
                    }
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler?(Response.error(NetworkError.dataMissingError, report: report))
                }
                return
            }

            report?.responseBody = String(data:data, encoding:.utf8)?.jsonIndented() ?? "Unable to decode body"

            if let httpResponse = response as? HTTPURLResponse {

                report?.statusCode = httpResponse.statusCode
                report?.responseHeaders = httpResponse.allHeaderFields

                if (httpResponse.statusCode >= 400) {
                    DispatchQueue.main.async {
                        completionHandler?(Response.error(NetworkError.httpError(statusCode: httpResponse.statusCode, description: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), data:data), report: report))
                    }
                    return
                }
            }

            DispatchQueue.main.async {
                completionHandler?(Response.success(data, report: report))
            }

        }
        return task
    }

    public func runRequest(request: URLRequest, completionHandler: CompletionHandler? = nil) {
        self.createTask(request: request, completionHandler: completionHandler).resume()
    }

    public func request(server: String, endPoint: EndPoint, parameters: [String:Any]?, method: HTTPMethod, completionHandler: CompletionHandler? = nil) {

        do {
            let request = try self.createRequest(server: server, endPoint: endPoint, parameters: parameters, method: method)
            self.runRequest(request: request, completionHandler: completionHandler)
        } catch {
            completionHandler?(Response.error(NetworkError.errorCreatingRequest, report: RequestReport()))
        }

    }

}
