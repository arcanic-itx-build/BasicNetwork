//
//  DefaultCompletionHandler.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/05/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public let defaultCompletionHandler: CompletionHandler = {
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
