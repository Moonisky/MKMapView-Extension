//
//  MapViewExtension.swift
//
//  Created by Semper Idem on 15-4-6.
//  1st Edition Modified on 16-01-26.
//  Copyright (c) 2015-2016年 星夜暮晨(Semper_Idem). All rights reserved.
//

import UIKit
import MapKit

private let mercatorOffset = 268435456.0
private let mercatorRadius = 85445659.44705395

extension MKMapView {
    
    // MARK: - The Transiation Methods for MKMapView
    
    /// By setting this property, you can change map zoom level based on **current map center**.
    ///
    /// The level is between 0 and 18, level 0 means the highest camera height
    var zoomLevel: UInt {
        get {
            let region = self.region
            
            let centerPixelX = region.center.longitude.pixelSpaceXForLongitude
            let topLeftPixelX = (region.center.longitude - region.span.longitudeDelta / 2).pixelSpaceXForLongitude
            
            let scaledMapWidth = (centerPixelX - topLeftPixelX) * 2
            let mapSizeInPixels = self.bounds.size
            let zoomScale = scaledMapWidth / Double(mapSizeInPixels.width)
            let zoomExponent = log(zoomScale) / log(2)
            let zoomLevel = 20 - zoomExponent
            
            return UInt(ceil(zoomLevel))
        }
        set (newZoomLevel) {
            self.setCenterCoordinate(self.centerCoordinate, zoomLevel: newZoomLevel, animated: true)
        }
    }
    
    /// Set current map zoom level based on center coordinate, you also can decided whether it should animate when the map region is changing.
    func setCenterCoordinate(centerCoordinate: CLLocationCoordinate2D, zoomLevel: UInt, animated: Bool ) {
        // clamp large numbers to 28
        let zoomLevel = min(zoomLevel, 28)
        
        // use the zoom level to compute the region
        let span = self.coordinateSpanWithCenterCoordinate(centerCoordinate, andZoomLevel: zoomLevel)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        // set the region like normal
        self.setRegion(region, animated: animated)
    }
    
    /// Get corresponding map region based on zoom level and center coordinate.
    func getCoordinateRegionWithCenterCoordinate(var centerCoordinate: CLLocationCoordinate2D, andZoomLevel: UInt) -> MKCoordinateRegion {
        // clamp lat/long values to appropriate ranges
        centerCoordinate.latitude = min(max(-90, centerCoordinate.latitude), 90)
        centerCoordinate.longitude = fmod(centerCoordinate.longitude, 180)
        
        // convert center coordinate to pixel space
        let centerPixelX = centerCoordinate.longitude.pixelSpaceXForLongitude
        let centerPixelY = centerCoordinate.latitude.pixelSpaceYForLatitude
        
        // determine the scale value from the zoom level
        let zoomExponent = 20 - zoomLevel
        let zoomScale = pow(2, Double(zoomExponent))
        
        // scale the map's size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the postion of the left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        
        // find delta between left and right longitudes
        let minLng = topLeftPixelX.longitudeForPixelSpaceX
        let maxLng = (topLeftPixelX + scaledMapWidth).longitudeForPixelSpaceX
        let longitudeDelta = maxLng - minLng
        
        // if we're at a pole then calculate the distance from the pole towards the equator
        // as MKMapView doesn't like drawing boxes over the poles
        var topPixelY = centerPixelY - (scaledMapHeight / 2)
        var bottomPixelY = centerPixelY + (scaledMapHeight / 2)
        var adjustedCenterPoint = false
        if topPixelY > mercatorOffset * 2 {
            topPixelY = centerPixelY - scaledMapHeight
            bottomPixelY = mercatorOffset * 2
            adjustedCenterPoint = true
        }
        
        // find delta between top and bottom latitudes
        let minLat = topPixelY.latitudeForPixelSpaceY
        let maxLat = bottomPixelY.latitudeForPixelSpaceY
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // create and return the lat/lng span
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        var region = MKCoordinateRegion(center: centerCoordinate, span: span)
        // once again, MKMapView doesn't like drawing boxes over the poles
        // so adjust the center coordinate to the center of the resulting region
        if adjustedCenterPoint { region.center.latitude = ((bottomPixelY + topPixelY) / 2).latitudeForPixelSpaceY }
        return region
    }
    
    func zoomIn() {
        let zoomLevel = self.zoomLevel
        self.zoomLevel = zoomLevel + 1
    }
    
    func zoomOut() {
        let zoomLevel = self.zoomLevel
        self.zoomLevel = zoomLevel - 1
    }
    
    // MARK: Map UI Handle
    
    /// A Boolean indicating whether the map displays a compass view.
    @available(iOS, deprecated=9.0, message="showsCompassView is deprecated in iOS 9.0, please use \"showsCompass\" instead")
    var showsCompassView: Bool {
        set(show) {
            if let compassView = MapComponent.sharedInstance.compassView {
                self.decideView(compassView, shouldShow: show)
            }
            // If not exist, then found it
            guard let compassView = self.findViewWithName("MKCompassView") else { return }
            MapComponent.sharedInstance.compassView = compassView
            self.decideView(compassView, shouldShow: show)
        }
        get {
            if MapComponent.sharedInstance.compassView == nil { return true }
            return self.findViewWithName("MKCompassView") != nil
        }
    }
    
    /// A Boolean indicating whether the map displays the lower left attributed label.
    var showsLegalLabel: Bool {
        set(show) {
            if let legalLabel = MapComponent.sharedInstance.legalLabel {
                self.decideView(legalLabel, shouldShow: show)
            }
            // If not exist, then found it
            guard let legalLabel = self.findViewWithName("MKAttributionLabel") else { return }
            MapComponent.sharedInstance.legalLabel = legalLabel
            self.decideView(legalLabel, shouldShow: show)
        }
        get {
            if MapComponent.sharedInstance.legalLabel == nil { return true }
            return self.findViewWithName("MKAttributionLabel") != nil
        }
    }
    
    /// A Boolean indicating whether the map displays the lower right image
    /// which is presented the map info provider.
    ///
    /// -Warning: If you decided to use this property, you have to ensure that
    /// there's no any UIImageViews added to MKMapView. If you really needs to add image view
    /// onto the mapView, you should set the mapView's tag to any value expect 0.
    /// Or this property may remove the wrong image.
    var showsMapInfoImageView: Bool {
        set(show) {
            if let mapInfoImageView = MapComponent.sharedInstance.mapInfoImageView {
                self.decideView(mapInfoImageView, shouldShow: show)
            }
            // If not exist, then found it
            guard let mapInfoImageView = self.findViewWithName(nil, OrClass: UIImageView.self) else { return }
            MapComponent.sharedInstance.mapInfoImageView = mapInfoImageView
            self.decideView(mapInfoImageView, shouldShow: show)
        }
        get {
            if MapComponent.sharedInstance.mapInfoImageView == nil { return true }
            return self.findViewWithName(nil, OrClass: UIImageView.self) != nil
        }
    }
    
    // MARK: Helper Methods
    
    private func findViewWithName(name: String? = nil, OrClass className: AnyClass? = nil) -> UIView? {
        var cla: AnyClass? = className
        if let name = name, className = NSClassFromString(name) {
            cla = className
        }
        if cla == nil { return nil }
        for view in self.subviews where view.isKindOfClass(cla!) {
            if view is UIImageView && view.tag != 0 { return nil }  // Handle Image View
            return view
        }
        return nil
    }
    
    private func decideView(view: UIView, shouldShow show: Bool) {
        if show {
            self.addSubview(view)
        } else {
            view.removeFromSuperview()
        }
    }
    
    private func coordinateSpanWithCenterCoordinate(center: CLLocationCoordinate2D, andZoomLevel zoomLevel: UInt) -> MKCoordinateSpan {
        // convert center coordinate to pixel space
        let centerPixelX = center.longitude.pixelSpaceXForLongitude
        let centerPixelY = center.latitude.pixelSpaceYForLatitude
        
        // determine the scale value from the zoom level
        let zoomExponent = Double(20 - zoomLevel)
        let zoomScale = pow(2, zoomExponent)
        
        // scale the map's size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        
        // find delta between left and right longitudes
        let minLng = topLeftPixelX.longitudeForPixelSpaceX
        let maxLng = (topLeftPixelX + scaledMapWidth).longitudeForPixelSpaceX
        let longitudeDelta = maxLng - minLng
        
        // find delta between top and bottom latitudes
        let minLat = topLeftPixelY.latitudeForPixelSpaceY
        let maxLat = (topLeftPixelY + scaledMapHeight).latitudeForPixelSpaceY
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // Create and return the lat/lng span
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}

// MARK: Map Conversion Methods

private extension Double {
    var pixelSpaceXForLongitude: Double {
        return round(mercatorOffset + mercatorRadius * self * M_PI / 180)
    }
    
    var pixelSpaceYForLatitude: Double {
        if self == 90 { return 0 }
        else if self == -90 { return mercatorOffset * 2 }
        else { return round(mercatorOffset - mercatorRadius * log((1 + sin(self * M_PI / 180)) / (1 - sin(self * M_PI / 180))) / 2) }
    }
    
    var longitudeForPixelSpaceX: Double {
        return ((round(self) - mercatorOffset) / mercatorRadius) * 180 / M_PI
    }
    
    var latitudeForPixelSpaceY: Double {
        return (M_PI / 2 - 2 * atan(exp((round(self) - mercatorOffset) / mercatorRadius))) * 180 / M_PI
    }
}

// MARK: Rects

extension MKMapRect {
    static var zero: MKMapRect { return MKMapRect(x: 0, y: 0, width: 0, height: 0) }
    static var null: MKMapRect { return MKMapRectNull }
    static var infinite: MKMapRect {
        let max = DBL_MAX
        let origin = -max / 2
        return MKMapRectMake(origin, origin, max, max)
    }
    
    init(x: Double, y: Double, width: Double, height: Double) {
        self.init(origin: MKMapPoint(x: x, y: y), size: MKMapSize(width: width, height: height))
    }
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: MKMapPoint(x: Double(x), y: Double(y)), size: MKMapSize(width: Double(width), height: Double(height)))
    }
    init(x: Int, y: Int, width: Int, height: Int) {
        self.init(origin: MKMapPoint(x: Double(x), y: Double(y)), size: MKMapSize(width: Double(width), height: Double(height)))
    }
    
    var width: Double { return MKMapRectGetWidth(self.standardized) }
    var height: Double { return MKMapRectGetHeight(self.standardized) }
    var minX: Double { return MKMapRectGetMinX(self.standardized) }
    var midX: Double { return MKMapRectGetMidX(self.standardized) }
    var maxX: Double { return MKMapRectGetMaxX(self.standardized) }
    var minY: Double { return MKMapRectGetMinY(self.standardized) }
    var midY: Double { return MKMapRectGetMidY(self.standardized) }
    var maxY: Double { return MKMapRectGetMaxY(self.standardized) }
    
    var isNull: Bool { return MKMapRectIsNull(self.standardized) }
    var isEmpty: Bool { return MKMapRectIsEmpty(self.standardized) }
    var isInfinite: Bool { return self == MKMapRect.infinite }
    var standardized: MKMapRect {
        let realWidth = abs(self.size.width)
        let realHeight = abs(self.size.height)
        let realX = self.size.width < 0 ? self.origin.x + self.size.width : self.origin.x
        let realY = self.size.height < 0 ? self.origin.y + self.size.height : self.origin.y
        return MKMapRect(x: realX, y: realY, width: realWidth, height: realHeight) }
    var integral: MKMapRect { return MKMapRect(x: floor(self.minX), y: floor(self.minY), width: ceil(self.width), height: ceil(self.height)) }
    
    mutating func standardizeInPlace() { self = standardized }
    mutating func makeIntegralInPlace() { self = integral }
    
    @warn_unused_result(mutable_variant="insetInPlace")
    func insetBy(dx dx: Double, dy: Double) -> MKMapRect { return MKMapRectInset(self.standardized, dx, dy) }
    
    mutating func insetInPlace(dx dx: Double, dy: Double) { self = insetBy(dx: dx, dy: dy) }
    
    @warn_unused_result(mutable_variant="offsetInPlace")
    func offsetBy(dx dx: Double, dy: Double) -> MKMapRect { return MKMapRectOffset(self.standardized, dx, dy) }
    
    mutating func offsetInPlace(dx dx: Double, dy: Double) { self = offsetBy(dx: dx, dy: dy) }
    
    @warn_unused_result(mutable_variant="unionInPlace")
    func union(rect: MKMapRect) -> MKMapRect { return MKMapRectUnion(self.standardized, rect.standardized) }
    
    mutating func unionInPlace(rect: MKMapRect) { self = union(rect.standardized) }
    
    @warn_unused_result(mutable_variant = "intersectInPlace")
    func intersect(rect: MKMapRect) -> MKMapRect { return MKMapRectIntersection(self.standardized, rect.standardized) }
    
    mutating func intersectInPlace(rect: MKMapRect) { self = intersect(rect.standardized) }
    
    @warn_unused_result
    func divide(atDistance: Double, fromEdge: MKMapRectEdge) -> (slice: MKMapRect, remainder: MKMapRect) {
        var slice = MKMapRect.zero
        var remainder = MKMapRect.zero
        MKMapRectDivide(self.standardized, &slice, &remainder, atDistance, fromEdge)
        return (slice, remainder)
    }
    
    @warn_unused_result
    func contains(rect: MKMapRect) -> Bool { return MKMapRectContainsRect(self.standardized, rect.standardized) }
    
    @warn_unused_result
    func contains(point: MKMapPoint) -> Bool { return MKMapRectContainsPoint(self.standardized, point) }
    
    @warn_unused_result
    func intersects(rect: MKMapRect) -> Bool { return MKMapRectIntersectsRect(self.standardized, rect.standardized) }
}

extension MKMapRect: Equatable { }

public func ==(lhs: MKMapRect, rhs: MKMapRect) -> Bool {
    return MKMapRectEqualToRect(lhs.standardized, rhs.standardized)
}

// MARK: Points

public extension MKMapPoint {
    static var zero: MKMapPoint { return MKMapPoint(x: 0, y: 0) }
    
    init(x: Int, y: Int) {
        self.init(x: Double(x), y: Double(y))
    }
    init(x: CGFloat, y: CGFloat) {
        self.init(x: Double(x), y: Double(y))
    }
}

extension MKMapPoint: Equatable { }

@warn_unused_result
public func ==(lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

// MARK: Sizes

extension MKMapSize {
    static var zero: MKMapSize { return MKMapSize(width: 0, height: 0) }
    
    init(width: Int, height: Int) {
        self.init(width: Double(width), height: Double(height))
    }
    init(width: CGFloat, height: CGFloat) {
        self.init(width: Double(width), height: Double(height))
    }
}

extension MKMapSize: Equatable { }

@warn_unused_result
public func ==(lhs: MKMapSize, rhs: MKMapSize) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}

public typealias MKMapRectEdge = CGRectEdge

// MARK: Helper Structure

/// The structure saving the removing view in order to re-add
private struct MapComponent {
    var compassView: UIView?
    var legalLabel: UIView?
    var mapInfoImageView: UIView?
    static var sharedInstance = MapComponent()
}