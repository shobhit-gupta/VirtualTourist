//
//  VirtualTouristUITests.swift
//  VirtualTouristUITests
//
//  Created by Shobhit Gupta on 20/02/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import XCTest

class VirtualTouristUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func checkIfMapFullSize(in app: XCUIApplication) {
        let map = app.maps.element
        // Unlike MapView, App frame size doesn't change with change in orientation, hence just compare the area.
        XCTAssertEqual(map.frame.height * map.frame.width, app.frame.height * app.frame.width)
    }
    
    
    func checkIfMapFullSize(in app: XCUIApplication, forOrientations orientations: [UIDeviceOrientation]) {
        for orientation in orientations {
            XCUIDevice.shared().orientation = orientation
            sleep(1)    // MapView needs some time to rotate.
            checkIfMapFullSize(in: app)
        }
    }
    
    
    func testMap() {
        
        let app = XCUIApplication()
        let orientations: [UIDeviceOrientation]
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            orientations = [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]
        } else {
            // Expected Phone orientations.
            orientations = [.portrait, .landscapeLeft, .landscapeRight]
        }
        checkIfMapFullSize(in: app, forOrientations: orientations)
        
    }
    
}
