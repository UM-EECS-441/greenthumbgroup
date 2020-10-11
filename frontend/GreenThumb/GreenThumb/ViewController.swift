//
//  ViewController.swift
//  GreenThumb
//
//  Created by Megan Worrel on 10/5/20.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var searchbar: UISearchBar!
    let locationManager = CLLocationManager()
    var gardenCoords = [CLLocationCoordinate2D]()
    var plantCoords = [CLLocationCoordinate2D]()
    @IBOutlet weak var iconPicker: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 39.8283, longitude: -98.5795, zoom: 2.0)
        self.map.camera = camera
        self.map.mapType = .satellite
        map.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func makeGarden(){
        let path = GMSMutablePath()
        for coord in self.gardenCoords{
            path.add(CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude))
        }

        let polygon = GMSPolygon(path: path)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = self.map
    }
    
    @IBAction func drawGardenTap(_ sender: UIButton) {
        makeGarden()
    }
    


}

extension ViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            marker.title = "Current Location"
            marker.map = self.map
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 21.0)
            self.map.camera = camera
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("error:: (error)")
    }
}


extension ViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let southWest = CLLocationCoordinate2D(latitude: coordinate.latitude-0.000008, longitude: coordinate.longitude+0.000008)
        let northEast = CLLocationCoordinate2D(latitude: coordinate.latitude+0.000008, longitude: coordinate.longitude-0.000008)
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)

        var icon: UIImage!
        if(iconPicker.selectedSegmentIndex == 0){
            icon = UIImage(named: "doticon.png")
            gardenCoords.append(coordinate)
        }
        else{
            icon = UIImage(named: "planticon.png")
            plantCoords.append(coordinate)
        }

        let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
        overlay.bearing = 0
        overlay.map = mapView
        overlay.isTappable = true
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MapPlant") as! MapPlant
        self.present(newViewController, animated: true, completion: nil)
    }
    
}

