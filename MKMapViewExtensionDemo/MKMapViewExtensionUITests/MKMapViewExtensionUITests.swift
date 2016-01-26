//
//  MKMapViewExtensionUITests.swift
//  MKMapViewExtensionUITests
//
//  Created by Semper_Idem on 16/1/26.
//  Copyright © 2016年 星夜暮晨. All rights reserved.
//

import XCTest

class MKMapViewExtensionUITests: XCTestCase {
        
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
    
    func testExample() {
        
        let app = XCUIApplication()
        app.buttons["Hide Lower Left Label"].tap()
        app.buttons["Show Lower Left Label"].tap()
        app.buttons["Hide Lower Right Image"].tap()
        app.buttons["Show Lower Right Image"].tap()
        
        let zoomInButton = app.buttons["Zoom In"]
        zoomInButton.tap()
        zoomInButton.tap()
        zoomInButton.tap()
        
        let zoomOutButton = app.buttons["Zoom Out"]
        zoomOutButton.tap()
        zoomOutButton.tap()
        zoomOutButton.tap()
        zoomOutButton.tap()
        zoomOutButton.tap()
    }
}
