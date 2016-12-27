# MKMapView-Extension

* [概述](#概述)
* [Introduction](#introduction)

## 概述

这是关于 `MKMapView` 写的一个基于 Swift 的扩展，可以扩展 `MKMapView` 的相关功能，减少复用代码量。

目前，本扩展支持以下几种功能：

- [x] 缩放等级


- [x] 可以决定某些删不掉的地图额外元素的显示


- [x] 为 `MKMapPoint`、`MKMapSize`、`MKMapRect` 添加了 Geometry 几何功能，就像 `CGPoint`、`CGSize`、`CGMapRect` 一样
- [ ] 添加文档
- [ ] 增加测试覆盖案例
- [ ] 添加 CocoaPods 支持
- [ ] 添加 Carthage 支持
- [ ] 添加 Swift Package Manager 支持

### 安装

将 `MapViewExtension.swift` 文件拖曳到您的项目中即可。

### 功能介绍

#### 缩放功能

缩放级别 (zoom level) 与对应的显示范围如下表所示：

| 缩放级别 |  海拔高度   | 对应的显示范围 |
| :--: | :-----: | :-----: |
|  18  |  200m   |  建筑级别   |
|  17  |  500m   |  建筑级别   |
|  16  |   1km   |   路级别   |
|  15  |   2km   |   路级别   |
|  14  |   5km   |  街道级别   |
|  13  |  10km   |  街道级别   |
|  12  |  20km   |   区级别   |
|  11  |  40km   |   区级别   |
|  10  |  80km   |   市级别   |
|  9   |  160km  |   市级别   |
|  8   |  320km  |   州级别   |
|  7   |  640km  |   州级别   |
|  6   | 1280km  |   省级别   |
|  5   | 2560km  |   省级别   |
|  4   | 5120km  |   国级别   |
|  3   | 10240km |   国级别   |
|  2   | 20480km |   洲级别   |
|  1   | 40960km |  全球级别   |

> 上表的显示范围并未严格定义，只是凭鄙人的视觉效果所判断的，如果大家有更好的建议，欢迎提出！此外，需要说明的一点是，显示范围是基于中国地图来进行判断的，因此在非中国地区使用的话请不要参考此显示范围。

### 参与代码贡献

我很欢迎大家来共同帮助完善和维护此项目，您可以提 Pull Request，也可以直接提 issue！

### 更新日志

### 2016.12.27

1. 版本更新至 Swift 3（感谢 [Shams Ahmed](https://github.com/shams-ahmed) 的 [PR](https://github.com/Moonisky/MKMapView-Extension/pull/1)）
2. 修改了访问权限
3. 完善了相关注释
4. 补完 `MKMapPoint`、`MKMapSize`、`MKMapRect` 等遗漏的一些简便扩展。

#### 2016.01.26

1. 增加了移除右下角“高德地图”图片的方法
2. 之前的 ZoomLevel 实现机制不再可用，因此换用 [Troy Brant](http://troybrant.net/blog) 所介绍的方法。
3. 现在移除地图额外元素之后，你还可以将它们添加回去了
4. 为 `MKMapPoint`、`MKMapSize` 和 `MKMapRect` 增加了大量的几何功能扩展，并提供了一个测试应用，你可以通过该应用来检测本扩展的功能，并且还提供了单元测试。

#### 2015.04.08

1. 增加了iOS 移除指南针和左下角属性标签的方法
2. 重写了获取 ZoomLevel 的实现机制，代码更加精简，并且由函数变更为属性，方便使用。（在此感谢微博[@102errors](http://weibo.com/102errors?from=usercardnew)同学提供的意见）原来的墨卡托坐标系的转换方法不再保留。

#### 2015.04.07

增加了“ZoomLevel”（缩放等级）的获取和设置

------

## Introduction

This is a MKMapView extension written by Swift for supporting zoom level, the code is referenced from Troy Brant's [Blog](http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/).

> Thanks for [Shams Ahmed](https://github.com/shams-ahmed)'s help, I decided to update this project again ^_^.

From now on, this extension supports the following functionalities:

- [x] Zoom level


- [x] You can decide whether to show the addtional map components which cannot be removed normally


- [x] Add geometrical capability extensions for `MKMapPoint`, `MKMapSize` and `MKMapRect`, just like `CGPoint`, `CGSize` and `CGMapRect`
- [ ] Add some documentation to methods and parameters
- [ ] Improve test coverage 
- [ ] Support Cocoapods
- [ ] Support Carthage
- [ ] Support Swift Package Manager

### Installation

Grab the `MapViewExtension.swift` and drag it into your project.

### Compatibility

#### Zoom

You can find the relationship between zoom level and altitude in following table:

| zoomlevel | altitude | the coresponding map extent |
| :-------: | :------: | :-------------------------: |
|    18     |   200m   |          Building           |
|    17     |   500m   |          Building           |
|    16     |   1km    |            Alley            |
|    15     |   2km    |            Alley            |
|    14     |   5km    |           Street            |
|    13     |   10km   |           Avenue            |
|    12     |   20km   |          District           |
|    11     |   40km   |          District           |
|    10     |   80km   |           County            |
|     9     |  160km   |           County            |
|     8     |  320km   |            Town             |
|     7     |  640km   |            City             |
|     6     |  1280km  |          Province           |
|     5     |  2560km  |          Province           |
|     4     |  5120km  |           Nation            |
|     3     | 10240km  |           Nation            |
|     2     | 20480km  |          Continent          |
|     1     | 40960km  |           Global            |

> The map extent which in the table above aren't defined strictly, it's' just diceded by my own eyesight. If you have better advices, please contact me or send a PR. And, what need to be explained is that, the map extent is based on China, so if you are in other country, please do not use this map extent as reference.

### Contributing

Contributions to the project are welcome. PR or issue are both OK for me.

### Update Log

### 2016.12.27

1. Update project to Swift 3 (Thanks for Shams Ahmed](https://github.com/shams-ahmed)'s [PR](https://github.com/Moonisky/MKMapView-Extension/pull/1)).
2. expose access levels.
3. complete comments.
4. complete `MKMapPoint`、`MKMapSize`、`MKMapRect` extensions.

#### 2016.01.26

1. Add the method that removing the image at the lower right corner.
2. Former solution for zoom level couldn't' use anymore, so I use the solution that Troy Brant introduced.
3. Now, after removing the additional map components, you can add them back to the map.
4. I also supply a demo by which you can test the functionalites that this extension provide. Furthermore, I also implement the unit test for checking the work of MKMapPoint, etc.