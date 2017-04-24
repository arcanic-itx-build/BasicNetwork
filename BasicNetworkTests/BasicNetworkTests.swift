//
//  BasicNetworkTests.swift
//  BasicNetworkTests
//
//  Created by Theis Egeberg on 24/04/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import XCTest
@testable import BasicNetwork

class BasicNetworkTests: XCTestCase {
    
    var network:BasicNetwork?
    
    override func setUp() {
        super.setUp()
        self.network = BasicNetwork()
    }
    
    func testRequestWithoutParams() {
        if let network = self.network {
            network.server = "http://google.com"
            network.request(endPoint: BasicNetwork.EndPoint(""), parameters: nil, method: .get, completionHandler: { (response) in
                switch response {
                case .error(let error, report: let report):
                    print(report.prettyPrint())
                case .success(let data, report: let report):
                    print(report.prettyPrint())
                }
            })
            
            
        }
    }
    
    
}
