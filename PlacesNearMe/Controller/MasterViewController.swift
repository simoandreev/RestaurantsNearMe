//
//  MasterViewController.swift
//  PlacesNearMe
//
//  Created by Simeon Andreev on 14.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class MasterViewController: UITableViewController {

	let radius = 3000
	let contentType = "restaurant"
	var detailViewController: DetailViewController? = nil
	var objects = [Any]()
	var placesClient: GMSPlacesClient!
	var locationManager: CLLocationManager?
	var userLocation = CLLocation()
	var didFindLocation = false
	let placeService: PlaceService = PlaceServiceManager.shared
	var places = [Place]() {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let split = splitViewController {
		    let controllers = split.viewControllers
		    detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
		navigationController?.navigationBar.prefersLargeTitles = true
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestAlwaysAuthorization()
		locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		locationManager?.startUpdatingLocation()
	}
	
	private func fetchPlaces(withLocation location: CLLocation) {
		self.places = []
		
		placeService.fetchPlaces(params: ["location":"\(location.coordinate.latitude),\(location.coordinate.longitude)","radius":"\(radius)","type":"\(contentType)"], successHandler: {[unowned self] (response) in
			self.places = response.results
			if UIDevice.current.userInterfaceIdiom == .pad {
				let initialIndexPath = IndexPath(row: 0, section: 0)
				self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableView.ScrollPosition.none)
				self.performSegue(withIdentifier: "showDetail", sender: initialIndexPath)
			}
		})
		{ (error) in
			print(error.localizedDescription)
		}
	}

	// MARK: - Segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			if let indexPath = tableView.indexPathForSelectedRow {
				let object = places[indexPath.row]
				let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
				controller.detailItemID = object.placeId
				controller.title = object.name
				controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}

	// MARK: - Table View
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let object = places[indexPath.row]
		cell.textLabel!.text = object.name
		
		//Measure distance betwen 2 objects
		let currentLocationCoordinate = CLLocation(latitude: self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude)
		let placeCoordinate = CLLocation(latitude: object.geometry.location.lat, longitude: object.geometry.location.lng)
		let distanceInMeters = currentLocationCoordinate.distance(from: placeCoordinate)
		cell.detailTextLabel!.text = "\(Int(distanceInMeters)) m"
		return cell
	}
}

extension MasterViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if !didFindLocation {
			self.userLocation = locations.last!
			fetchPlaces(withLocation: self.userLocation)
			locationManager?.stopUpdatingLocation()
			didFindLocation = true
		}
	}
}
