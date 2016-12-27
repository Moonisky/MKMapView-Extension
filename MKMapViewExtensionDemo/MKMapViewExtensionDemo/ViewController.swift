//
//  ViewController.swift
//  MKMapViewExtensionDemo
//
//  Created by Semper_Idem on 16/1/25.
//  Copyright © 2016年 星夜暮晨. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
  
  // MARK: Properties
  
  @IBOutlet private weak var mapView: MKMapView!
  @IBOutlet private weak var lblZoomLevel: UILabel!
  @IBOutlet private weak var btnCompass: UIButton!
  private var locationManager: CLLocationManager!
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    lblZoomLevel.adjustsFontSizeToFitWidth = true
    if CLLocationManager.locationServicesEnabled() {
      locationManager = CLLocationManager()
      locationManager.requestWhenInUseAuthorization()
      locationManager.delegate = self
      locationManager.startUpdatingLocation()
      locationManager.startUpdatingHeading()
      
      mapView.userTrackingMode = .followWithHeading
      btnCompass.isHidden = false
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    lblZoomLevel.text = "Current Zoom Level: \(mapView.zoomLevel)"
  }
  
  // MARK: Actions
  
  @IBAction func handleLBAttributedLabel(_ sender: UIButton) {
    let showsAttributionLabel = mapView.showsLegalLabel
    sender.setTitle(showsAttributionLabel ? "Show Label" : "Hide Label", for: UIControlState())
    mapView.showsLegalLabel = !showsAttributionLabel
  }
  
  @IBAction func handleRBImageView(_ sender: UIButton) {
    let showsImageView = mapView.showsMapInfoImageView
    sender.setTitle(showsImageView ? "Show Image" : "Hide Image", for: UIControlState())
    mapView.showsMapInfoImageView = !showsImageView
  }
  
  @IBAction func handleZoomIn(_ sender: UIButton) {
    mapView.zoomIn()
    lblZoomLevel.text = "Current Zoom Level: \(mapView.zoomLevel)"
  }
  
  @IBAction func handleZoomOut(_ sender: UIButton) {
    mapView.zoomOut()
    lblZoomLevel.text = "Current Zoom Level: \(mapView.zoomLevel)"
  }
  
  @IBAction func handleCompass(_ sender: UIButton) {
    let showsCompass: Bool
    if #available(iOS 9.0, *) {
      showsCompass = mapView.showsCompass
    } else {
      showsCompass = mapView.showsCompassView
    }
    sender.setTitle(showsCompass ? "Show Compass" : "Hide Compass", for: UIControlState())
    if #available(iOS 9.0, *) {
      mapView.showsCompass = !showsCompass
    } else {
      mapView.showsCompassView = !showsCompass
    }
  }
}

extension ViewController: CLLocationManagerDelegate { }
