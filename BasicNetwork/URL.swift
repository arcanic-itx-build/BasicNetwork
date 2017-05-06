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

        let queryString = parameters.flatMap { (keyValue) -> String? in
            return "\(keyValue.key)=\(keyValue.value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            }.joined(separator: "&")

        return URL(string: "\(self.absoluteString)?\(queryString)")!
    }

}
