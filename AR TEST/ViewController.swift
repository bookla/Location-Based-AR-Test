//
//  ViewController.swift
//  AR TEST
//
//  Created by Book Lailert on 30/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {
    
    var addPlace = false

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        CLLocationManager().requestWhenInUseAuthorization()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateMap()
    }
    
    func updateMap() {
         if let places = UserDefaults.standard.array(forKey: "places") {
             if let placeList = places as? [[String: Any]] {
                 self.populateMap(placeList: placeList)
             }
         }
    }
    
    func populateMap(placeList:[[String: Any]]) {
        var i = 0
        for eachPlace in placeList {
            let name = eachPlace["name"] as! String
            let lat = eachPlace["lat"] as! Double
            let long = eachPlace["long"] as! Double
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = PlaceAnnotation(location: location, title: name, index: i)
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
            i += 1
        }
    }

    @IBOutlet var mapView: MKMapView!
    
    func saveLocation(name:String, coordinates:CLLocationCoordinate2D, altitude:Double) {
        let lat = coordinates.latitude as Double
        let long = coordinates.longitude as Double
        let data = ["name": name, "lat": lat, "long": long, "alt": altitude] as [String : Any]
        if let places = UserDefaults.standard.array(forKey: "places") {
            if var placeList = places as? [[String: Any]] {
                placeList.append(data)
                UserDefaults.standard.set(placeList, forKey: "places")
            }
        } else {
            UserDefaults.standard.set([data], forKey: "places")
        }
        updateMap()
    }
    
    @IBAction func tap(_ sender: Any) {
        print("TAP")
    }
    
    @IBAction func mapHold(_ sender: UILongPressGestureRecognizer) {
        if addPlace {
            if sender.state == .changed {
                let locationInView = sender.location(in: self.mapView)
                
                if self.mapView.frame.contains(locationInView) {
                    let locationInMap = self.mapView.convert(locationInView, toCoordinateFrom: self.mapView)
                    let alert = UIAlertController(title: "Add a place", message: "Please enter the name of the place.", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.placeholder = "Place Name"
                    }
                    alert.addTextField { (textField) in
                        textField.placeholder = "Altitude (Default: 10m)"
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
                        let textField = alert.textFields![0]
                        let name = textField.text!
                        if let alt =  alert.textFields![1].text {
                            if alt.isNumber {
                                self.saveLocation(name: name, coordinates: locationInMap, altitude: Double(alt)!)
                            } else {
                                self.saveLocation(name: name, coordinates: locationInMap, altitude: 10)
                            }
                        } else {
                            self.saveLocation(name: name, coordinates: locationInMap, altitude: 10)
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func addPlace(_ sender: Any) {
        if !addPlace {
            addPlace = true
            self.title = "Press and hold to add a place"
            addButton.setImage(UIImage(systemName: "multiply"), for: .normal)
        } else {
            addPlace = false
            self.title = "Map View"
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            
        }
    }
    
    @IBAction func enterAR(_ sender: Any) {
        addPlace = false
        self.title = "Map View"
        addButton.imageView?.image = UIImage(named: "plus")
        self.performSegue(withIdentifier: "enterAR", sender: nil)
    }
    
    @IBOutlet var addButton: UIButton!
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
