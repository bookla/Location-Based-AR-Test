//
//  ARViewController.swift
//  AR TEST
//
//  Created by Book Lailert on 1/7/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit
import CoreLocation
import ARKit

class ARViewController: UIViewController, CLLocationManagerDelegate, ARSKViewDelegate {
    
    let locationManager = CLLocationManager()
    let ARView = ARSKView()
    var waitingLocation = false
    var anchorName = [UUID: String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        ARView.delegate = self
        
        let scene = SKScene(size: view.bounds.size)
        ARView.presentScene(scene)
        view.addSubview(ARView)
        
        waitingLocation = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    
        
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if !granted {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ARView.frame = view.bounds
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if waitingLocation {
            waitingLocation = false
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.worldAlignment = .gravityAndHeading
            ARView.session.run(configuration, options:[.resetTracking])
            placePins(center: locations.last)
        }
    }
    
    func getPinLocations() -> ([String: CLLocation]) {
        var pins = [String: CLLocation]()
        if let places = UserDefaults.standard.array(forKey: "places") {
            if let placeList = places as? [[String: Any]] {
                 for eachPlace in placeList {
                    let name = eachPlace["name"] as! String
                    let lat = eachPlace["lat"] as! Double
                    let long = eachPlace["long"] as! Double
                    var alt = 10.0
                    if let loadedAltitude = eachPlace["alt"] as? Double {
                        alt = loadedAltitude
                    }
                    let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let pinLocation = CLLocation(coordinate: coordinates, altitude: alt, horizontalAccuracy: CLLocationAccuracy(exactly: 0)!, verticalAccuracy: CLLocationAccuracy(exactly: 0)!, timestamp: Date())
                    pins[name] = pinLocation
                }
            }
        }
        return pins
    }
    
    
    func placePins(center:CLLocation?) {
        if let center = center {
            let pinLocations = getPinLocations()
            for pinName in pinLocations.keys {
                let pinLocation = pinLocations[pinName]!
                let transformation = getTransformation(from: center, to: pinLocation)
                let anchor = ARAnchor(transform: transformation)
                anchorName[anchor.identifier] = pinName
                anchor.name = String(pinName)
                ARView.session.add(anchor: anchor)
            }
        }
    }
    
    func getTransformation(from center: CLLocation, to pin: CLLocation) -> simd_float4x4 {
        let distance = center.distance(from: pin)
        let distanceTransform = simd_float4x4.translatingIdentity(x: 0, y: 0, z: -min(Float(distance), 99))
        
        let rotation = Matrix.angle(from: center, to: pin)
        
        let tilt = Matrix.angleOffHorizon(from: center, to: pin)
        
        let tiltedTransformation = Matrix.rotateVertically(matrix: distanceTransform, around: tilt)
        let completedTransformation = Matrix.rotateHorizontally(matrix: tiltedTransformation, around: -rotation)
        return completedTransformation
    }
    
    
    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 4000, height: 700))
        backgroundView.backgroundColor = UIColor.white
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 100
        
        let label = UILabel(frame: backgroundView.frame)
        label.text = anchorName[anchor.identifier]
        label.font = UIFont.boldSystemFont(ofSize: 300)
        label.textAlignment = .center
        
        backgroundView.addSubview(label)
        
        //let labelImage = UIImage(named: "testIcon")!
        var labelImage = backgroundView.asImage()
        
        labelImage = resizeImage(image: labelImage, targetSize: CGSize(width: 4000, height: 700))
        
        let labelNode = SKSpriteNode(texture: SKTexture(image: labelImage))
        labelNode.name = anchor.identifier.uuidString
        node.addChild(labelNode)
    }
    
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            self.navigationController?.popToRootViewController(animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
     func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Compass Error", message: "Compass is temporarily unavailable, unable to start AR. Please try again later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: { (nil) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

