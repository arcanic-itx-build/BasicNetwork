//
//  Response.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 17/05/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public enum Response {
    case error(Error, report:RequestReport?)
    case success(Data, report:RequestReport?)
}
