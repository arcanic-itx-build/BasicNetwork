//
//  BasicNetworkError.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 30/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public enum NetworkError: LocalizedError {
    case httpError(statusCode:Int, description:String, data:Data)
    case urlCreationError(String)
    case dataMissingError
    case errorCreatingRequest
    case underlyingError(Error)

    public var errorDescription: String? {
        switch self {
        case .httpError(statusCode: let statusCode, description: let description, let data):
            return "HTTP error: [\(statusCode)] \(description) \(String(data:data, encoding:.utf8) ?? "No body"))"
        case .urlCreationError(let urlString):
            return "Failed to create url from string '\(urlString)'"
        case .dataMissingError:
            return "Server didn't respond with any data"
        case .underlyingError(let error):
            return "Underlying error: \(error.localizedDescription)"
        case .errorCreatingRequest:
            return "Error creating request"
        }
    }

}
