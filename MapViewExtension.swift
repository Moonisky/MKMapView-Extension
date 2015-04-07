//
//  MapViewExtension.swift
//  WENT-iOS
//
//  Created by Semper Idem on 15-4-6.
//  Copyright (c) 2015年 星夜暮晨. All rights reserved.
//

import UIKit
import MapKit

private let MERCATOR_OFFSET:Double = 268435456
private let MERCATOR_RADIUS:Double = 85445659.44705395

extension MKMapView {
    
    // MARK: - 地图相关的转换方法
    
    /// 获取当前一个经度对应多少像素值（空间的X值）
    func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180)
    }
    
    /// 获取当前一个纬度对应多少像素值（空间的Y值）
    func latitudeToPixelSpaceY(latitude: Double) -> Double {
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * Double(logf((1 + sinf(Float(latitude * M_PI / 180))) / (1 - sinf(Float(latitude * M_PI / 180))))) / 2)
    }
    
    /// 获取当前像素值（空间的X值）对应多少经度
    func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180 / M_PI
    }
    
    /// 获取当前像素值（空间的Y值）对应多少纬度
    func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (M_PI / 2 - 2 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180 / M_PI
    }
    
    /// 获取 MKMapView 的缩放级别
    func getZoomLevel() -> Double {
        // 当前用户可见的地图
        let currentRegion = self.region
        // 当前可视区域的三维坐标
        let currentSpan = currentRegion.span
        // 当前可视区域的中心（角度表示法）
        let currentCenterCoordinate = currentRegion.center
        // 获取当前可视区域左右两边的纬度
        let leftLongitude = currentCenterCoordinate.longitude - (currentSpan.longitudeDelta / 2)
        let rightLongitude = currentCenterCoordinate.longitude + (currentSpan.longitudeDelta / 2)
        // 当前显示视窗的尺寸大小（像素）
        let mapSizeInPixels = self.bounds.size
        
        // 获取屏幕左右两边的完整缩放像素大小
        let leftPixel = self.longitudeToPixelSpaceX(leftLongitude)
        let rightPixel = self.longitudeToPixelSpaceX(rightLongitude)
        // 屏幕宽度
        let pixelDelta = abs(rightPixel - leftPixel)
        
        // 实际上显示的像素值
        let zoomScale = Double(mapSizeInPixels.width) / Double(pixelDelta)
        // 反转指数
        let zoomExponent = log2(zoomScale)
        // 调整比例
        let zoomLevel = zoomExponent + 20
        return zoomLevel
    }
    
    /// 根据缩放级别来获取目的区域的三维坐标
    func coordinateSpanWithMapView(mapView: MKMapView, centerCoordinate center: CLLocationCoordinate2D, andZoomLevel level: UInt) -> MKCoordinateSpan {
        
        // 将中心经纬度转换为像素空间
        let centerPixelX = self.longitudeToPixelSpaceX(center.longitude)
        let centerPixelY = self.latitudeToPixelSpaceY(center.latitude)
        
        // 根据缩放级别决定比例值
        let zoomExponent = 20 - level
        let zoomScale = pow(2, Double(zoomExponent))
        
        // 在像素区域内设置地图尺寸比例
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // 设定左上角像素位置
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        
        // 寻找左右经度的三维坐标值
        let minLng = self.pixelSpaceXToLongitude(topLeftPixelX)
        let maxLng = self.pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        // 寻找上下纬度的三维坐标值
        let minLat = self.pixelSpaceYToLatitude(topLeftPixelY)
        let maxLat = self.pixelSpaceYToLatitude(topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // 创建并返回三维坐标
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        return span
    }
    
    /// 以缩放级别来设置当前地图中心点
    func setCenterCoordinate(center: CLLocationCoordinate2D, zoomLevel level: UInt, animated: Bool) {
        // 设置缩放级别的最大值为28
        let zoomLevel = min(level, 28)
        
        // 使用缩放级别来计算区域
        let newSpan = self.coordinateSpanWithMapView(self, centerCoordinate: center, andZoomLevel: level)
        let newRegion = MKCoordinateRegionMake(center, newSpan)
        
        self.setRegion(newRegion, animated: animated)
    }
    
    /// 缩放级别放大一级
    func zoomIn() -> Bool {
        var zoomLevel = self.getZoomLevel()
        let center = self.userLocation.coordinate
        zoomLevel += 1.0
        if zoomLevel > 18 {
            return false
        }else {
            self.setCenterCoordinate(center, zoomLevel: UInt(zoomLevel), animated: true)
            return true
        }
    }
    
    /// 缩放级别缩小一级
    func zoomOut() -> Bool {
        var zoomLevel = self.getZoomLevel()
        let center = self.userLocation.coordinate
        zoomLevel -= 1.0
        if zoomLevel < 0 {
            return false
        }else {
            self.setCenterCoordinate(center, zoomLevel: UInt(zoomLevel), animated: true)
            return true
        }
    }
}