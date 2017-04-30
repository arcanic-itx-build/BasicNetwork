//
//  EndPoint.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 30/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public struct EndPoint:CustomStringConvertible {
    private let parts:[String]

    public var description: String {
        get {
            return parts.joined(separator: "/")
        }
    }

    public init(_ part:String...) {
        parts = part
    }
}
