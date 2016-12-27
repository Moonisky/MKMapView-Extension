//
//  MKMapViewExtensionTests.swift
//  MKMapViewExtensionTests
//
//  Created by Semper_Idem on 16/1/26.
//  Copyright © 2016年 星夜暮晨. All rights reserved.
//

import XCTest
import MapKit

class MKMapViewExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("You may begin.")
    }
    
    override func tearDown() {
        super.tearDown()
        print("Test Finished")
    }
    
    func testPoint() {
        var pt: MKMapPoint
        
        pt = MKMapPoint(x: 1.25, y: 2.25)
        print("named float literals" + "\(pt)")
        pointTest(pt, withAimPoint: (1.25, 2.25))
        pt = MKMapPoint(x: 1, y: 2)
        print("named int literals" + "\(pt)")
        pointTest(pt, withAimPoint: (1, 2))
        pt = MKMapPoint(x: cgfloat1, y: cgfloat2)
        print("named CGFloat" + "\(pt)")
        pointTest(pt, withAimPoint: (1, 2))
        pt = MKMapPoint(x: double1, y: double2)
        print("named Double" + "\(pt)")
        pointTest(pt, withAimPoint: (1, 2))
        pt = MKMapPoint(x: int1, y: int2)
        print("named Int" + "\(pt)")
        pointTest(pt, withAimPoint: (1, 2))
        
        XCTAssert(pt != MKMapPoint.zero)
    }
    
    func testSize() {
        var size: MKMapSize
        
        size = MKMapSize(width: -1.25, height: -2.25)
        print("named float literals" + "\(size)")
        sizeTest(size, withAimSize: (-1.25, -2.25))
        size = MKMapSize(width: -1, height: -2)
        print("named int literals" + "\(size)")
        sizeTest(size, withAimSize: (-1, -2))
        size = MKMapSize(width: cgfloat1, height: cgfloat2)
        print("named CGFloat" + "\(size)")
        sizeTest(size, withAimSize: (1, 2))
        size = MKMapSize(width: double1, height: double2)
        print("named Double" + "\(size)")
        sizeTest(size, withAimSize: (1, 2))
        size = MKMapSize(width: int1, height: int2)
        print("named Int" + "\(size)")
        sizeTest(size, withAimSize: (1, 2))
        
        XCTAssert(size != MKMapSize.zero)
    }
    
    func testRect() {
        var rect: MKMapRect
        
        let pt = MKMapPoint(x: 10.25, y: 20.25)
        let size = MKMapSize(width: 30.25, height: 40.25)
        rect = MKMapRect(origin: MKMapPoint(x: 10.25, y: 20.25), size: MKMapSize(width: 30.25, height: 40.25))
        print("point+size" + "\(rect)")
        rectTest(rect, withAimRect: (10.25, 20.25, 30.25, 40.25))
        rect = MKMapRect(origin: pt, size: size)
        print("named point+size" + "\(rect)")
        rectTest(rect, withAimRect: (10.25, 20.25, 30.25, 40.25))
        
        rect = MKMapRect(x: 10.25, y: 20.25, width: 30.25, height: 40.25)
        print("named float literals" + "\(rect)")
        rectTest(rect, withAimRect: (10.25, 20.25, 30.25, 40.25))
        rect = MKMapRect(x: 10, y: 20, width: 30, height: 40)
        print("named int literals" + "\(rect)")
        rectTest(rect, withAimRect: (10, 20, 30, 40))
        rect = MKMapRect(x: cgfloat1, y: cgfloat2, width: cgfloat3, height: cgfloat4)
        print("named CGFloat" + "\(rect)")
        rectTest(rect, withAimRect: (1, 2, 3, 4))
        rect = MKMapRect(x: double1, y: double2, width: double3, height: double4)
        print("named Double" + "\(rect)")
        rectTest(rect, withAimRect: (1, 2, 3, 4))
        rect = MKMapRect(x: int1, y: int2, width: int3, height: int4)
        print("named Int" + "\(rect)")
        rectTest(rect, withAimRect: (1, 2, 3, 4))
        
        XCTAssert(rect == rect)
        XCTAssert(rect != MKMapRect.zero)
        XCTAssert(!rect.isNull)
        XCTAssert(!rect.isEmpty)
        XCTAssert(!rect.isInfinite)
        XCTAssert(MKMapRect.null.isNull)
        XCTAssert(MKMapRect.zero.isEmpty)
        XCTAssert(MKMapRect.infinite.isInfinite)
        
        var unstandard = MKMapRect(x: 10, y: 20, width: -30, height: -50)
        let standard = unstandard.standardized
        print("unstandard " + "\(unstandard)")
        print("standard " + "\(standard)")
        rectTest(unstandard, withAimRect: (10, 20, -30, -50))
        rectTest(standard, withAimRect: (-20, -30, 30, 50))
        
        XCTAssert(unstandard.width == 30)
        XCTAssert(unstandard.size.width == -30)
        XCTAssert(standard.width == 30)
        XCTAssert(standard.size.width == 30)
        
        XCTAssert(unstandard.height == 50)
        XCTAssert(unstandard.size.height == -50)
        XCTAssert(standard.height == 50)
        XCTAssert(standard.size.height == 50)
        
        XCTAssert(unstandard.minX == -20)
        XCTAssert(unstandard.midX == -5)
        XCTAssert(unstandard.maxX == 10)
        
        XCTAssert(unstandard.minY == -30)
        XCTAssert(unstandard.midY == -5)
        XCTAssert(unstandard.maxY == 20)
        
        XCTAssert(unstandard == standard)
        XCTAssert(unstandard.standardized == standard)
        
        unstandard.standardizeInPlace()
        print("standardized unstandard" + "\(unstandard)")
        rectTest(unstandard, withAimRect: (-20, -30, 30, 50))
        
        rect = MKMapRect(x: 11.25, y: 22.25, width: 33.25, height: 44.25)
        print("insetBy" + "\(rect.insetBy(1, -2))")
        rectTest(rect.insetBy(1, -2), withAimRect: (12.25, 20.25, 31.25, 48.25))
        rect.insetInPlace(1, -2)
        print("insetInPlace" + "\(rect)")
        rectTest(rect, withAimRect: (12.25, 20.25, 31.25, 48.25))
        
        rect = MKMapRect(x: 11.25, y: 22.25, width: 33.25, height: 44.25)
        print("offsetBy" + "\(rect.offsetBy(3, -4))")
        rectTest(rect.offsetBy(3, -4), withAimRect: (14.25, 18.25, 33.25, 44.25))
        rect.offsetInPlace(3, -4)
        print("offsetInPlace" + "\(rect)")
        rectTest(rect, withAimRect: (14.25, 18.25, 33.25, 44.25))
        
        rect = MKMapRect(x: 11.25, y: 22.25, width: 33.25, height: 44.25)
        print("integral" + "\(rect.integral)")
        rectTest(rect.integral, withAimRect: (11, 22, 34, 45))
        rect.makeIntegralInPlace()
        print("makeIntegralInPlace" + "\(rect)")
        rectTest(rect, withAimRect: (11, 22, 34, 45))
        
        let smallRect = MKMapRect(x: 10, y: 25, width: 5, height: -5)
        let bigRect = MKMapRect(x: 1, y: 2, width: 101, height: 102)
        let distantRect = MKMapRect(x: 1000, y: 2000, width: 1, height: 1)
        
        rect = MKMapRect(x: 11.25, y: 22.25, width: 33.25, height: 44.25)
        print("union small" + "\(rect.union(smallRect))")
        rectTest(rect.union(smallRect), withAimRect: (10, 20, 34.5, 46.5))
        print("union big" + "\(rect.union(bigRect))")
        rectTest(rect.union(bigRect), withAimRect: (1, 2, 101, 102))
        print("union distant" + "\(rect.union(distantRect))")
        rectTest(rect.union(distantRect), withAimRect: (11.25, 22.25, 989.75, 1978.75))
        
        rect.unionInPlace(smallRect)
        rect.unionInPlace(bigRect)
        rect.unionInPlace(distantRect)
        print("unionInPlace" + "\(rect)")
        rectTest(rect, withAimRect: (1, 2, 1000, 1999))
        
        rect = MKMapRect(x: 11.25, y: 22.25, width: 33.25, height: 44.25)
        print("intersect small" + "\(rect.intersect(smallRect))")
        rectTest(rect.intersect(smallRect), withAimRect: (11.25, 22.25, 3.75, 2.75))
        print("intersect big" + "\(rect.intersect(bigRect))")
        rectTest(rect.intersect(bigRect), withAimRect: (11.25, 22.25, 33.25, 44.25))
        print("intersect distant" + "\(rect.intersect(distantRect))")
        rectTest(rect.intersect(distantRect), withAimRect: (Double.infinity, Double.infinity, 0, 0))
        
        XCTAssert(rect.intersects(smallRect))
        rect.intersectInPlace(smallRect)
        XCTAssert(!rect.isEmpty)
        
        XCTAssert(rect.intersects(bigRect))
        rect.intersectInPlace(bigRect)
        XCTAssert(!rect.isEmpty)
        
        XCTAssert(!rect.intersects(distantRect))
        rect.intersectInPlace(distantRect)
        XCTAssert(rect.isEmpty)
        
        rect = MKMapRect(x: 11.25, y: 22.25, width: 33.25, height: 44.25)
        XCTAssert(rect.contains(MKMapPoint(x: 15, y: 25)))
        XCTAssert(!rect.contains(MKMapPoint(x: -15, y: 25)))
        XCTAssert(bigRect.contains(rect))
        XCTAssert(!rect.contains(bigRect))
        
        rect = MKMapRect(x: 11.25, y: 22.25, width: 33.25, height: 44.25)
        let (slice, remainder) = rect.divide(5, fromEdge: .minXEdge)
        print("slice" + "\(slice)")
        print("remainder" + "\(remainder)")
        rectTest(slice, withAimRect: (11.25, 22.25, 5, 44.25))
        rectTest(remainder, withAimRect: (16.25, 22.25, 28.25, 44.25))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: Test Cases Const
    let int1: Int = 1
    let int2: Int = 2
    let int3: Int = 3
    let int4: Int = 4
    
    let cgfloat1: CGFloat = 1
    let cgfloat2: CGFloat = 2
    let cgfloat3: CGFloat = 3
    let cgfloat4: CGFloat = 4
    
    let double1: Double = 1
    let double2: Double = 2
    let double3: Double = 3
    let double4: Double = 4
    
    // MARK: Test Helper
    fileprivate func pointTest(_ point: MKMapPoint, withAimPoint aimPoint: (Double, Double)) {
        XCTAssert(point.x == aimPoint.0 && point.y == aimPoint.1)
    }
    
    fileprivate func sizeTest(_ size: MKMapSize, withAimSize aimSize: (Double, Double)) {
        XCTAssert(size.width == aimSize.0 && size.height == aimSize.1)
    }
    
    fileprivate func rectTest(_ rect: MKMapRect, withAimRect aimRect: (Double, Double, Double, Double)) {
        XCTAssert(rect.origin.x == aimRect.0 && rect.origin.y == aimRect.1 && rect.size.width == aimRect.2 && rect.size.height == aimRect.3)
    }
}
