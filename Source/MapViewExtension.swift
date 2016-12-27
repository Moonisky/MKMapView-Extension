y//
//  MapViewExtension.swift
//
//  Created by Semper Idem on 15-4-6.
//  1st Edition Modified on 16-01-26.
//  Copyright (c) 2015-2016年 星夜暮晨(Semper_Idem). All rights reserved.
//

import Foundation
import UIKit
import MapKit

private let mercatorOffset: Double = 268435456.0
private let mercatorRadius: Double = 85445659.44705395

public extension MKMapView {
  
  // MARK: - The Transiation Methods for MKMapView
  
  /// By setting this property, you can change map zoom level based on **current map center**.
  ///
  /// - Note: The level is between 0 and 18, level 0 means the highest camera height.
  public var zoomLevel: UInt {
    get {
      let centerPixelX = region.center.longitude.pixelSpaceXForLongitude
      let topLeftPixelX = (region.center.longitude - region.span.longitudeDelta / 2).pixelSpaceXForLongitude
      
      let scaledMapWidth = (centerPixelX - topLeftPixelX) * 2
      let zoomScale = scaledMapWidth / Double(bounds.width)
      let zoomExponent = log(zoomScale) / log(2)
      let zoomLevel = 20 - zoomExponent
      
      return UInt(ceil(zoomLevel))
    }
    set (newZoomLevel) {
      self.setCenterCoordinate(centerCoordinate, zoomLevel: newZoomLevel, animated: true)
    }
  }
  
  /// Set current map zoom level based on center coordinate,
  /// you also can decided whether it should animate when the map region is changing.
  /// 
  /// - Parameters:
  ///   - centerCoordinate: the aim coordinate that you want set it to center
  ///   - zoomLevel: a unsigned int which is between 0 and 18, level 0 means the highest camera height
  ///   - animated: determine whether moving map animately
  public func setCenterCoordinate(_ centerCoordinate: CLLocationCoordinate2D, zoomLevel: UInt, animated: Bool ) {
    // clamp large numbers to 28
    let zoomLevel = min(zoomLevel, 28)
    
    // use the zoom level to compute the region
    let span = coordinateSpanWithCenterCoordinate(centerCoordinate, zoomLevel: zoomLevel)
    let region = MKCoordinateRegion(center: centerCoordinate, span: span)
    
    // set the region like normal
    self.setRegion(region, animated: animated)
  }
  
  /// Get corresponding map region based on zoom level and center coordinate.
  ///
  /// - Parameters:
  ///   - centerCoordinate: the center coordinate of the region you want to get
  ///   - zoomLevel: a unsigned int which is between 0 and 18, level 0 means the highest camera height
  ///
  /// - Returns: corresponding region
  public func getCoordinateRegion(_ centerCoordinate: CLLocationCoordinate2D, zoomLevel: UInt) -> MKCoordinateRegion {
    // clamp lat/long values to appropriate ranges
    var centerCoordinate = centerCoordinate
    centerCoordinate.latitude = min(max(-90, centerCoordinate.latitude), 90)
    centerCoordinate.longitude = fmod(centerCoordinate.longitude, 180)
    
    // convert center coordinate to pixel space
    let centerPixelX = centerCoordinate.longitude.pixelSpaceXForLongitude
    let centerPixelY = centerCoordinate.latitude.pixelSpaceYForLatitude
    
    // determine the scale value from the zoom level
    let zoomExponent = 20 - zoomLevel
    let zoomScale = pow(2, Double(zoomExponent))
    
    // scale the map's size in pixel space
    let mapSizeInPixels = bounds.size
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
  
  /// Increase zoom level by 1
  ///
  /// - Note: the max zoom level is 18.
  public func zoomIn() {
    zoomLevel += 1
  }
  
  /// Decrease zoom level by 1
  ///
  /// - Note: the min zoom level is 1.
  public func zoomOut() {
    zoomLevel -= 1
  }
  
  // MARK: Map UI Handle
  
  /// A Boolean indicating whether the map displays a compass view.
  ///
  /// - Requires: iOS 9.0 and above
  /// - Note: if you want to use it below the iOS 9, please use `showsCompass` instead.
  @available(iOS, deprecated: 9.0, message: "showsCompassView is deprecated in iOS 9.0, please use \"showsCompass\" instead")
  public var showsCompassView: Bool {
    set(show) {
      if let compassView = MapComponent.sharedInstance.compassView {
        self.decideView(compassView, shouldShow: show)
      }
      // If not exist, then found it
      guard let compassView = findView("MKCompassView") else { return }
      MapComponent.sharedInstance.compassView = compassView
      self.decideView(compassView, shouldShow: show)
    }
    get {
      if MapComponent.sharedInstance.compassView == nil { return true }
      return self.findView("MKCompassView") != nil
    }
  }
  
  /// A Boolean indicating whether the map displays the lower left attributed label.
  public var showsLegalLabel: Bool {
    set(show) {
      if let legalLabel = MapComponent.sharedInstance.legalLabel {
        decideView(legalLabel, shouldShow: show)
      }
      // If not exist, then found it
      guard let legalLabel = findView("MKAttributionLabel") else { return }
      MapComponent.sharedInstance.legalLabel = legalLabel
      decideView(legalLabel, shouldShow: show)
    }
    get {
      if MapComponent.sharedInstance.legalLabel == nil { return true }
      return findView("MKAttributionLabel") != nil
    }
  }
  
  /// A Boolean indicating whether the map displays the lower right image
  /// which is presented the map info provider.
  ///
  /// - Warning: If you decided to use this property, you have to ensure that
  /// there's no any UIImageViews added to MKMapView. If you really needs to add image view
  /// onto the mapView, you should set the mapView's tag to any value expect 0.
  /// Or this property may remove the wrong image.
  public var showsMapInfoImageView: Bool {
    set(show) {
      if let mapInfoImageView = MapComponent.sharedInstance.mapInfoImageView {
        decideView(mapInfoImageView, shouldShow: show)
      }
      // If not exist, then found it
      guard let mapInfoImageView = findView(nil, className: UIImageView.self) else { return }
      MapComponent.sharedInstance.mapInfoImageView = mapInfoImageView
      decideView(mapInfoImageView, shouldShow: show)
    }
    get {
      if MapComponent.sharedInstance.mapInfoImageView == nil { return true }
      return findView(nil, className: UIImageView.self) != nil
    }
  }
}

// MARK: Rects

public extension MKMapRect {
  /// The rect that contains every map point in the world.
  public static var world: MKMapRect { return MKMapRectWorld }
  public static var zero: MKMapRect { return MKMapRect(x: 0, y: 0, width: 0, height: 0) }
  public static var null: MKMapRect { return MKMapRectNull }
  public static var infinite: MKMapRect {
    let max = DBL_MAX
    let origin = -max / 2
    return MKMapRectMake(origin, origin, max, max)
  }
  
  public init(x: Double, y: Double, width: Double, height: Double) {
    self.init(origin: MKMapPoint(x: x, y: y), size: MKMapSize(width: width, height: height))
  }
  public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
    self.init(origin: MKMapPoint(x: Double(x), y: Double(y)), size: MKMapSize(width: Double(width), height: Double(height)))
  }
  public init(x: Int, y: Int, width: Int, height: Int) {
    self.init(origin: MKMapPoint(x: Double(x), y: Double(y)), size: MKMapSize(width: Double(width), height: Double(height)))
  }
  
  public var width: Double { return MKMapRectGetWidth(self.standardized) }
  public var height: Double { return MKMapRectGetHeight(self.standardized) }
  public var minX: Double { return MKMapRectGetMinX(self.standardized) }
  public var midX: Double { return MKMapRectGetMidX(self.standardized) }
  public var maxX: Double { return MKMapRectGetMaxX(self.standardized) }
  public var minY: Double { return MKMapRectGetMinY(self.standardized) }
  public var midY: Double { return MKMapRectGetMidY(self.standardized) }
  public var maxY: Double { return MKMapRectGetMaxY(self.standardized) }
  
  public var isNull: Bool { return MKMapRectIsNull(self.standardized) }
  public var isEmpty: Bool { return MKMapRectIsEmpty(self.standardized) }
  public var isInfinite: Bool { return self == MKMapRect.infinite }
  public var standardized: MKMapRect {
    let realWidth = abs(self.size.width)
    let realHeight = abs(self.size.height)
    let realX = self.size.width < 0 ? self.origin.x + self.size.width : self.origin.x
    let realY = self.size.height < 0 ? self.origin.y + self.size.height : self.origin.y
    return MKMapRect(x: realX, y: realY, width: realWidth, height: realHeight) }
  public var integral: MKMapRect { return MKMapRect(x: floor(self.minX), y: floor(self.minY), width: ceil(self.width), height: ceil(self.height)) }
  
  public mutating func standardizeInPlace() { self = standardized }
  public mutating func makeIntegralInPlace() { self = integral }
  
  public func insetBy(_ dx: Double, _ dy: Double) -> MKMapRect { return MKMapRectInset(self.standardized, dx, dy) }
  
  public mutating func insetInPlace(_ dx: Double, _ dy: Double) { self = insetBy(dx, dy) }
  
  public func offsetBy(_ dx: Double, _ dy: Double) -> MKMapRect { return MKMapRectOffset(self.standardized, dx, dy) }
  
  public mutating func offsetInPlace(_ dx: Double, _ dy: Double) { self = offsetBy(dx, dy) }
  
  public func union(_ rect: MKMapRect) -> MKMapRect { return MKMapRectUnion(self.standardized, rect.standardized) }
  
  public mutating func unionInPlace(_ rect: MKMapRect) { self = union(rect.standardized) }
  
  public func intersect(_ rect: MKMapRect) -> MKMapRect { return MKMapRectIntersection(self.standardized, rect.standardized) }
  
  public mutating func intersectInPlace(_ rect: MKMapRect) { self = intersect(rect.standardized) }
  
  public func divide(_ atDistance: Double, fromEdge: MKMapRectEdge) -> (slice: MKMapRect, remainder: MKMapRect) {
    var slice = MKMapRect.zero
    var remainder = MKMapRect.zero
    MKMapRectDivide(self.standardized, &slice, &remainder, atDistance, fromEdge)
    return (slice, remainder)
  }
  
  public func contains(_ rect: MKMapRect) -> Bool { return MKMapRectContainsRect(self.standardized, rect.standardized) }
  
  public func contains(_ point: MKMapPoint) -> Bool { return MKMapRectContainsPoint(self.standardized, point) }
  
  public func intersects(_ rect: MKMapRect) -> Bool { return MKMapRectIntersectsRect(self.standardized, rect.standardized) }
}

public extension MKMapRect {
  public var coordinateRegion: MKCoordinateRegion {
    return MKCoordinateRegionForMapRect(self)
  }
  
  public var mapRectSpans180thMeridian: Bool {
    return MKMapRectSpans180thMeridian(self)
  }
  
  /// For map rects that span the 180th meridian, this returns the portion of the rect
  /// that lies outside of the world rect wrapped around to the other side of the
  /// world.  The portion of the rect that lies inside the world rect can be
  /// determined with rect.intersect(MKMapRect.world).
  public var mapRectRemainder: MKMapRect {
    return MKMapRectRemainder(self)
  }
}

extension MKMapRect: Equatable { }

public func == (lhs: MKMapRect, rhs: MKMapRect) -> Bool {
  return MKMapRectEqualToRect(lhs.standardized, rhs.standardized)
}

extension MKMapRect: CustomStringConvertible {
  public var description: String {
    return MKStringFromMapRect(self)
  }
}

// MARK: Points

public extension MKMapPoint {
  public static var zero: MKMapPoint { return MKMapPoint(x: 0, y: 0) }
  
  public init(x: Int, y: Int) {
    self.init(x: Double(x), y: Double(y))
  }
  public init(x: CGFloat, y: CGFloat) {
    self.init(x: Double(x), y: Double(y))
  }
}

public extension MKMapPoint {
  /// Conversion between unprojected and projected coordinates
  public var coordinate: CLLocationCoordinate2D { return MKCoordinateForMapPoint(self) }
  
  public func getMeters(to mapPoint: MKMapPoint) -> CLLocationDistance {
    return MKMetersBetweenMapPoints(self, mapPoint)
  }
}

extension MKMapPoint: Equatable { }

public func == (lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y
}

extension MKMapPoint: CustomStringConvertible {
  public var description: String {
    return MKStringFromMapPoint(self)
  }
}

// MARK: Sizes

public extension MKMapSize {
  public static var zero: MKMapSize { return MKMapSize(width: 0, height: 0) }
  /// The size that contains every map point in the world.
  public static var world: MKMapSize { return MKMapSizeWorld }
  
  public init(width: Int, height: Int) {
    self.init(width: Double(width), height: Double(height))
  }
  public init(width: CGFloat, height: CGFloat) {
    self.init(width: Double(width), height: Double(height))
  }
}

extension MKMapSize: Equatable { }

public func == (lhs: MKMapSize, rhs: MKMapSize) -> Bool {
  return lhs.width == rhs.width && lhs.height == rhs.height
}

extension MKMapSize: CustomStringConvertible {
  public var description: String {
    return MKStringFromMapSize(self)
  }
}

// MARK: Coordinate

public extension CLLocationCoordinate2D {
  /// Conversion between unprojected and projected coordinates
  public var mapPoint: MKMapPoint { return MKMapPointForCoordinate(self) }
}

// MARK: Degrees

public extension CLLocationDegrees {
  /// Conversion between distances and projected coordinates
  public var metersPerMapPoint: CLLocationDistance { return MKMetersPerMapPointAtLatitude(self) }
  /// Conversion between distances and projected coordinates
  public var mapPointsPerMeter: Double { return MKMapPointsPerMeterAtLatitude(self) }
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

// MARK: Helper Methods

fileprivate extension MKMapView {
  // MARK: Helper Methods
  
  fileprivate func findView(_ name: String? = nil, className: AnyClass? = nil) -> UIView? {
    var cla: AnyClass? = className
    if let name = name, let className = NSClassFromString(name) {
      cla = className
    }
    if cla == nil { return nil }
    for view in self.subviews where view.isKind(of: cla!) {
      if view is UIImageView && view.tag != 0 { return nil }  // Handle Image View
      return view
    }
    return nil
  }
  
  fileprivate func decideView(_ view: UIView, shouldShow show: Bool) {
    if show {
      self.addSubview(view)
      view.alpha = 0
      UIView.animate(withDuration: 0.5) {
        view.alpha = 1
      }
    } else {
      UIView.animate(withDuration: 0.5, animations: {
        view.alpha = 0
      }) { finish in
        view.removeFromSuperview()
      }
    }
  }
  
  fileprivate func coordinateSpanWithCenterCoordinate(_ center: CLLocationCoordinate2D, zoomLevel: UInt) -> MKCoordinateSpan {
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

fileprivate extension Double {
  
  fileprivate var pixelSpaceXForLongitude: Double {
    let result: Double = mercatorOffset + mercatorRadius * self * M_PI / 180
    
    return result.rounded()
  }
  
  fileprivate var pixelSpaceYForLatitude: Double {
    if self == 90 { return 0 }
    else if self == -90 { return mercatorOffset * 2 }
    else { return (mercatorOffset - mercatorRadius * log((1 + sin(self * M_PI / 180)) / (1 - sin(self * M_PI / 180))) / 2).rounded() }
  }
  
  fileprivate var longitudeForPixelSpaceX: Double {
    return ((self.rounded() - mercatorOffset) / mercatorRadius) * 180 / M_PI
  }
  
  fileprivate var latitudeForPixelSpaceY: Double {
    return (M_PI / 2 - 2 * atan(exp((self.rounded() - mercatorOffset) / mercatorRadius))) * 180 / M_PI
  }
}
