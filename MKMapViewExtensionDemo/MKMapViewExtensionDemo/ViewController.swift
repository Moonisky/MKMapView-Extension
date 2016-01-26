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

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var lblZoomLevel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lblZoomLevel.text = "Current Zoom Level: \(mapView.zoomLevel)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleLBAttributedLabel(sender: UIButton) {
        let showsAttributionLabel = mapView.showsLegalLabel
        sender.setTitle(showsAttributionLabel ? "Show Lower Left Label" : "Hide Lower Left Label", forState: .Normal)
        mapView.showsLegalLabel = !showsAttributionLabel
    }
    
    @IBAction func handleRBImageView(sender: UIButton) {
        let showsImageView = mapView.showsMapInfoImageView
        sender.setTitle(showsImageView ? "Show Lower Right Image" : "Hide Lower Right Image", forState: .Normal)
        mapView.showsMapInfoImageView = !showsImageView
    }

    @IBAction func handleZoomIn(sender: UIButton) {
        mapView.zoomIn()
        lblZoomLevel.text = "Current Zoom Level: \(mapView.zoomLevel)"
    }
    
    @IBAction func handleZoomOut(sender: UIButton) {
        mapView.zoomOut()
        lblZoomLevel.text = "Current Zoom Level: \(mapView.zoomLevel)"
    }
    
}

