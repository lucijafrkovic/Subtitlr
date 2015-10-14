//
//  OpenSubsAccessTests.swift
//  Subtitlr
//
//  Created by Lucija Frković on 27/09/15.
//  Copyright © 2015 Lucija Frković. All rights reserved.
//

import XCTest
@testable import Subtitlr

class OpenSubsAccessTests: XCTestCase {

    var subsAccess = OpenSubsAccess()
    
    override func setUp() {
        super.setUp()
        subsAccess.logIn()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLogIn(){
        subsAccess.logIn()
        XCTAssertNotNil(subsAccess.token)
        
    }
    
    func testTalkToOpenSubs(){
        /* test log in */
        let result = subsAccess.talkToOpenSubs("LogIn", params: ["", "", "eng", Constants.OSUserAgent])
        XCTAssertNotNil(result!.valueForKey("token"))
        
        let serverInfo = subsAccess.talkToOpenSubs("ServerInfo", params: [])
        print(serverInfo)
    }
    
    func testSearchSubs(){
        let file = Video(path: "/Users/spilja/Downloads/breakdance.avi")
        let result = subsAccess.getSubtitle(file.hash, size: Double(file.size))
        XCTAssertEqual(1951887680, result!.id)
        XCTAssertEqual("srt", result!.format)
    }
    
    //TODO: add entitlements to tests??
//    func testGetSubFile(){
//        var file = Video(path: "/Users/spilja/Downloads/breakdance.avi", subFound: false)
//        subsAccess.downloadSub(1951887680, format: "srt", file: &file)
//    }

}
