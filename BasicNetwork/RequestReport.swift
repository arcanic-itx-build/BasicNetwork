//
//  RequestReport.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 30/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public struct RequestReport {

    public var url: URL?
    public var method: HTTPMethod?
    public var statusCode: Int?
    public var requestHeaders: [String:String]?
    public var responseHeaders: [AnyHashable:Any]?
    public var responseBody: String?
    public var requestBody: String?

    public func prettyPrint() -> String {
        return "===> Request report [\(statusCode ?? -1)] =========||\n\(url?.absoluteString ?? "?") (\(method?.description ?? "?"))\n" +
            "\(requestBody ?? "[No request body]")\n" +
            "\(responseBody ?? "[No response body]")\n" +
        "=========\n"
    }

}
