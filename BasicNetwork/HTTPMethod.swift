//
//  HTTPMethod.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 30/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public enum HTTPMethod: CustomStringConvertible {

    public var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }

    case get, post(method:PostMethod)

}
