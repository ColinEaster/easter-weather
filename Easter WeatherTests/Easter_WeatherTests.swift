//
//  Easter_WeatherTests.swift
//  Easter WeatherTests
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import XCTest
@testable import Easter_Weather

class Easter_WeatherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testToFahrenheit() {
        XCTAssertEqual(Int(32), Int(toFahrenheit(273.15)))
        XCTAssertEqual(Int(440.33), Int(toFahrenheit(500.0)))
        XCTAssertEqual(Int(-99.67), Int(toFahrenheit(200.0)))
        XCTAssertEqual(Int(-459), Int(toFahrenheit(0.0)))
        XCTAssertEqual(Int(-5.17), Int(toFahrenheit(252.5)))
    }
    
    func testToCelsius(){
        XCTAssertEqual(Int(0), Int(toCelsius(273.15)))
        XCTAssertEqual(Int(-273.15), Int(toCelsius(0)))
        XCTAssertEqual(Int(50), Int(toCelsius(323.15)))
        XCTAssertEqual(Int(100.73), Int(toCelsius(373.88)))
        
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
