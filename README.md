# MKMapView-Extension
这是关于 MKMapView 写的一个基于swift的扩展，可以扩展 MKMapView 的相关功能，减少复用代码量。
This is a MKMapView extension written by Swift for supporting zoom level, the code is referenced from Troy Brant's [Blog](http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/).

目前，本扩展支持以下几种功能：
From now on, this extension support the following functionalities:

* 缩放等级 (zoom level)
* 可以决定某些删不掉的地图额外元素的显示 (you can decide whether to show the addtional map components which cannot be removed normally)
* 为 MKMapPoint、MKMapSize、MKMapRect 添加了 Geometry 几何功能，就像 CGPoint、CGSize、CGMapRect 一样 (add geometrical capability extensions for MKMapPoint, MKMapSize and MKMapRect, just like CGPoint, CGSize and CGMapRect)

##更新说明 (Update Log)
**2016.01.26**
1. 增加了移除右下角“高德地图”图片的方法
2. 之前的 ZoomLevel 实现机制不再可用，因此换用 [Troy Brant](http://troybrant.net/blog) 所介绍的方法。
3. 现在移除地图额外元素之后，你还可以将它们添加回去了
4. 为 MKMapPoint、MKMapSize 和 MKMapRect 增加了大量的几何功能扩展，并提供了一个测试应用，你可以通过该应用来检测本扩展的功能，并且还提供了单元测试。

1. Add the method that removing the image at the lower right corner.
2. Former solution for zoom level couldn't' use anymore, so I use the solution that Troy Brant introduced.
3. Now, after removing the additional map components, you can add them back to the map.
4. I also supply a demo by which you can test the functionalites that this extension provide. Furthermore, I also implement the unit test for checking the work of MKMapPoint, etc.

**2015.04.08**

1. 增加了iOS 移除指南针和左下角属性标签的方法
2. 重写了获取 ZoomLevel 的实现机制，代码更加精简，并且由函数变更为属性，方便使用。（在此感谢微博[@102errors](http://weibo.com/102errors?from=usercardnew)同学提供的意见）原来的墨卡托坐标系的转换方法不再保留。

**2015.04.07** 

增加了“ZoomLevel”（缩放等级）的获取和设置

## 功能介绍 (Introduction)

### 缩放功能 (zoom)

#### zoomLevel: UInt

通过设置该缩放级别，可以根据**当前地图中心**来改变地图视角大小。

By setting this property, you can change map zoom level based on **current map center**.

这是一个计算属性，它表示当前 MKMapView 的缩放级别，缩放级别从 0 级到 18 级，缩放级别与海拔高度的对应表如下所示：

This is a computed property, it's the current zoom level of MKMapView, the level is between 0 and 18. You can find the relationship between zoom level and altitude in following table:

| 缩放级别(zoomlevel) | 海拔高度(altitude) | 对应的显示范围(the coresponding map extent) |
| :------: | :-----: | :-----------: |
| 18     |   200m  |    建筑级别(Building)   |
| 17     |   500m  |    建筑级别(Building)   |
| 16     |   1km   |    路级别(Road)     |
| 15     |   2km   |    路级别(Road)      |
| 14     |   5km   |    街道级别(Street)     |
| 13     |   10km  |    街道级别(Street)     |
| 12     |   20km   |    区级别(Area)     |
| 11     |   40km   |    区级别(Area)     |
| 10     |   80km   |    市级别(City)     |
| 9      |   160km   |    市级别(City)     |
| 8      |   320km   |    州级别(State)     |
| 7      |   640km   |    州级别(State)     |
| 6      |   1280km   |    省级别(Province)     |
| 5      |   2560km   |    省级别(Province)     |
| 4      |   5120km   |    国级别(Nation)     |
| 3      |   10240km   |    国级别(Nation)     |
| 2      |   20480km   |    洲级别(Continent)     |
| 1      |   40960km   |    全球级别(Global)     |

> 上表的显示范围并未严格定义，只是凭鄙人的视觉效果所判断的，如果大家有更好的建议，欢迎提出！此外，需要说明的一点是，显示范围是基于中国地图来进行判断的，因此在非中国地区使用的话请不要参考此显示范围。

> The map extent which in the table above aren't defined strictly, it's' just diceded by my own eyesight. If you have better advices, please contact me or send a PR. And, what need to be explained is that, the map extent is based on China, so if you are in other country, please do not use this map extent as reference.

#### func setCenterCoordinate(centerCoordinate: CLLocationCoordinate2D, zoomLevel: UInt, animated: Bool)

这个函数基于中心点、缩放级别来设置当前地图缩放效果，你还可以控制缩放过程中是否显示动画。

Set current map zoom level based on center coordinate, you also can decided whether it should animate when the map region is changing.

#### getCoordinateRegionWithCenterCoordinate(centerCoordinate: CLLocationCoordinate2D, andZoomLevel: UInt) -> MKCoordinateRegion

基于中心点、缩放级别来获取对应的地图区域

Get corresponding map region based on zoom level and center coordinate.

#### zoomIn()

缩放级别增加一级 (zoom level is increased by 1)

#### zoomOut()

缩放级别减小一级 (zoom level is decreased by 1)

### 地图 UI 元素处理 (Map UI Components Handle)

#### showsCompassView: Bool

设定是否显示位于右上角的指南针视图。此属性在 iOS 9 之前的版本有效，由于 iOS 9 提供了自带的 `showsCompass` 属性，因此在  iOS 9 中请替换为系统的属性。

A Boolean indicating whether the map displays a compass view.

Deprecated in iOS 9.0, please use `showsCompass` provided by iOS 9 framework instead.

#### showsLegalLabel: Bool

设定是否显示位于左下角的法律信息标签 (Legal 字段)。

A Boolean indicating whether the map displays the lower left attributed label.

#### showsMapInfoImageView: Bool

决定是否显示位于右下角的地图信息提供商图片（高德地图）。注意，如果您决定使用此属性的话，请确保不要往 MKMapView 上添加任何的 UIImageView。如果您非要添加的话，请将该 UIImageView 的 tag 值设为除 0 之外的任何数，以防止此方法移除图片错误。

A Boolean indicating whether the map displays the lower right image which is presented the map info provider.

**Warning**: If you decided to use this property, you have to ensure that there's no any UIImageViews added to MKMapView. If you really needs to add image view onto the mapView, you should set the mapView's tag to any value expect 0. Or this property may remove the wrong image.

### 几何扩展 (Geometry Extension)

```Swift
extension MKMapSize {
    public static var zero: MKMapSize { get }
    public init(x: Int, y: Int)
    public init(x: CGFloat, y: CGFloat)
}

extension MKMapSize : Equatable { }

extension MKMapSize {
    public static var zero: MKMapSize { get }
    public init(width: Int, height: Int)
    public init(width: CGFloat, height: CGFloat)
}

extension MKMapSize : Equatable { }

extension MKMapRect {
    public static var zero: MKMapRect { get }
    public static var null: MKMapRect { get }
    public static var infinite: MKMapRect { get }
    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
    public init(x: Double, y: Double, width: Double, height: Double)
    public init(x: Int, y: Int, width: Int, height: Int)
    public var width: Double { get }
    public var height: Double { get }
    public var minX: Double { get }
    public var midX: Double { get }
    public var maxX: Double { get }
    public var minY: Double { get }
    public var midY: Double { get }
    public var maxY: Double { get }
    public var isNull: Bool { get }
    public var isEmpty: Bool { get }
    public var isInfinite: Bool { get }
    public var standardized: MKMapRect { get }
    public var integral: MKMapRect { get }
    public mutating func standardizeInPlace()
    public mutating func makeIntegralInPlace()
    @warn_unused_result(mutable_variant="insetInPlace")
    public func insetBy(dx dx: Double, dy: Double) -> MKMapRect
    public mutating func insetInPlace(dx dx: Double, dy: Double)
    @warn_unused_result(mutable_variant="offsetInPlace")
    public func offsetBy(dx dx: Double, dy: Double) -> MKMapRect
    public mutating func offsetInPlace(dx dx: Double, dy: Double)
    @warn_unused_result(mutable_variant="unionInPlace")
    public func union(rect: MKMapRect) -> MKMapRect
    public mutating func unionInPlace(rect: MKMapRect)
    @warn_unused_result(mutable_variant="intersectInPlace")
    public func intersect(rect: MKMapRect) -> MKMapRect
    public mutating func intersectInPlace(rect: MKMapRect)
    @warn_unused_result
    public func divide(atDistance: Double, fromEdge: MKMapRectEdge) -> (slice: MKMapRect, remainder: MKMapRect)
    @warn_unused_result
    public func contains(rect: MKMapRect) -> Bool
    @warn_unused_result
    public func contains(point: MKMapSize) -> Bool
    @warn_unused_result
    public func intersects(rect: MKMapRect) -> Bool
}

extension MKMapRect : Equatable { }
```
