//
//  ViewController.swift
//  intern
//
//  Created by Jian Zhai on 2018/1/22.
//  Copyright © 2018年 Jian Zhai. All rights reserved.
//

import UIKit
import MapKit

protocol SearchBarDelegate {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MainViewController: UIViewController, UIViewControllerTransitioningDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil

    let initialLocation = CLLocation(latitude: 37.331686, longitude: -122.030656)   // 1 infinite loop
    let regionRadius: CLLocationDistance = 1000
    
    var pinLocation:[Position] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        centerMapOnLocation(location: initialLocation)
        mapView.delegate = self
        
//        pinLocation = [
//            Position(title: "AAA", locationName: "aaa", coordinate: CLLocationCoordinate2D(latitude: 37.33, longitude: -122.03)),
//            Position(title: "BBB", locationName: "bbb", coordinate: CLLocationCoordinate2D(latitude: 37.335, longitude: -122.035))
//        ]
        
        if let path = Bundle.main.path(forResource: "test", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let locations = jsonResult["location"] as? [Any] {
                    for location in locations {
                        let item = location as! [String:String]
                        print(item)
                        pinLocation.append(Position(title: item["title"] ?? "no title",
                                                    locationName: item["locationName"] ?? "no location name",
                                                    coordinate: CLLocationCoordinate2D(latitude: Double(item["latitude"] ?? "0")!, longitude: Double(item["longitude"] ?? "0")!)))
                    }
                }
            } catch {
                // handle error
            }
        }
        
        // add search bar
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = mapView
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable

        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapSearchDelegate = self
        
        mapView.addAnnotations(pinLocation)

    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showMenu(_ sender: Any) {
        performSegue(withIdentifier: "showMenu", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MenuViewController {
            destinationViewController.transitioningDelegate = self
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }

}

extension MainViewController: SearchBarDelegate {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            print("\(city) \(state)")
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension MainViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 50, height: 50)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.titleLabel?.sizeToFit()
        
        if let annotation = annotation as? Position {
            if annotation.willBeSaved {
                
                button.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                button.setTitle("Saved", for: UIControlState.normal)
                button.addTarget(self, action: #selector(deleteDirection), for: .touchUpInside)
                
                pinView?.leftCalloutAccessoryView = button
                return pinView
            }
        }

        button.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.setTitle("Save", for: UIControlState.normal)
        button.addTarget(self, action: #selector(saveDirection), for: .touchUpInside)
        
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }

    @objc func saveDirection(){
        if let selectedPin = selectedPin {
            print("save")
            print(selectedPin.coordinate)
            
            var cityState:String = ""
            if let city = selectedPin.locality,
                let state = selectedPin.administrativeArea {
                print("\(city) \(state)")
                cityState = "\(city) \(state)"
            }
            
            let newLocation = Position(title: selectedPin.title ?? "no name", locationName: cityState, coordinate: selectedPin.coordinate)
            pinLocation.append(newLocation)
        }
    }
    
    @objc func deleteDirection(){
        if let selectedPin = selectedPin {
            print("delete")
            print(selectedPin.coordinate)
        }
    }
}

