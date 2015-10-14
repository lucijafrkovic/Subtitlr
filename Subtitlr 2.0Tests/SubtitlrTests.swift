//
//  Subtitlr_2_0Tests.swift
//  Subtitlr 2.0Tests
//
//  Created by Lucija Frković on 11/10/15.
//  Copyright © 2015 Lucija Frković. All rights reserved.
//

import XCTest
@testable import Subtitlr

class SubtitlrTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHashMethod(){
        let file = Video(path: "/Users/spilja/Downloads/breakdance.avi")
        XCTAssertEqual(file.hash, "8e245d9679d31e12")
    }
    
}
