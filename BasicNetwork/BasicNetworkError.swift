//
//  BasicNetworkError.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 30/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

public enum BasicNetworkError:Error {
    case httpError(statusCode:Int,description:String)
    case urlCreationError(String)
    case dataMissingError
}
