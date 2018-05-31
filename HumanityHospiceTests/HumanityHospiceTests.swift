//
//  HumanityHospiceTests.swift
//  HumanityHospiceTests
//
//  Created by App Center on 5/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import XCTest
import FirebaseCore
@testable import HumanityHospice

class HumanityHospiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testTimestamp() {
//        let timeInt = Date().timeIntervalSince1970
//        let timestamp = timeInt.toTimeStamp()
//        XCTAssertEqual(timestamp, "Today, 11:45 PM")
//    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            testTimestamp()
        }
    }
    
}
