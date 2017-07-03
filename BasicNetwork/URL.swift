//
//  URL.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 04/05/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

extension URL {

    public func withQueryStringParameters(parameters: [String:Any]) -> URL {
        return URL(string: "\(self.absoluteString)?\(URL.encodedParameters(parameters: parameters))")!
    }

    public static func encodedParameters(parameters: [String:Any]) -> String {
        return parameters.flatMap { (keyValue) -> String? in
            return "\(keyValue.key)=\(keyValue.value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            }.joined(separator: "&")
    }

}
