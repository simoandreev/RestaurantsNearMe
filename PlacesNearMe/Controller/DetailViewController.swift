//
//  DetailViewController.swift
//  PlacesNearMe
//
//  Created by Simeon Andreev on 14.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var mapKit: MKMapView!
	@IBOutlet weak var rating: UILabel!
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var phone: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var customRatingView: FloatRatingView!
	
	let distanceSpan: CLLocationDistance = 1000
	let placeService: PlaceService = PlaceServiceManager.shared
	var place: PlaceDetail?
	var location = CLLocation()
	var mapCoordinates = MKCoordinateRegion()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		mapKit.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellDetail")
	}
	
	var detailItemID: String? {
		didSet {
		    fetchDetailPlace()
		}
	}
	
	private func fetchDetailPlace() {
		//activityIndicatorView.startAnimating()
		placeService.fetchPlace(id: detailItemID!, successHandler: {[unowned self] response in
			//self.activityIndicatorView.stopAnimating()
			self.place = response
			print(self.place as Any)
			self.tableView.reloadData()
			
			//Map Kit view with annotation
			let annotation = MKPointAnnotation()
			if let location = self.place?.result.geometry.location {
				annotation.title = self.place?.result.name
				annotation.coordinate.latitude = location.lat
				annotation.coordinate.longitude = location.lng
				self.zoomLevel(locationLat: location.lat, locationLng: location.lng)
				self.mapKit.addAnnotation(annotation)
			}
			
			//Set Detail Screen properties
			self.rating.text = "Rating: \(self.place?.result.rating ?? 0)"
			self.price.text = "Price: \(self.place?.result.priceLevel ?? 0)"
			self.phone.text = "Phone: \(self.place?.result.formattedPhoneNumber ?? "")"
			self.address.text = "Address: \(self.place?.result.formattedAddress ?? "")"
			self.customRatingView.rating = Double(self.place?.result.rating ?? 0)
			
			if let photo = self.place?.result.photos?[0] {
				let url = URL(string: "\(PlaceServiceManager.shared.baseAPIURL)photo?maxwidth=800&photoreference=\(photo.photoReference)&key=\(PlaceServiceManager.shared.apiKey)")!
				self.downloadImage(from: url)
			}
			
			
			})
		{ (error) in
			print(error.localizedDescription)
			//self.activityIndicatorView.stopAnimating()
		}
	}
	
	func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
		URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
	}
	
	func downloadImage(from url: URL) {
		print("Download Started")
		getData(from: url) { data, response, error in
			guard let data = data, error == nil else { return }
			print(response?.suggestedFilename ?? url.lastPathComponent)
			print("Download Finished")
			DispatchQueue.main.async() {
				self.imageView.image = UIImage(data: data)
			}
		}
	}
}

extension DetailViewController:  UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.place?.result.openingHours?.weekdayText?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetail", for: indexPath)
		cell.textLabel?.text = self.place?.result.openingHours?.weekdayText?[indexPath.row]
		return cell
	}
}

extension DetailViewController: MKMapViewDelegate, CLLocationManagerDelegate {
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		let coordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
		let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: mapCoordinates.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: mapCoordinates.span)]
		let placemark = MKPlacemark(coordinate: coordinates)
		let mapItem = MKMapItem(placemark: placemark)
		if let annotationTitle = view.annotation?.title {
			mapItem.name = "\(annotationTitle!)"
			mapItem.openInMaps(launchOptions: options)
		}
	}
	
	private func zoomLevel(locationLat: Double, locationLng: Double) {
		// create new region for zoom level
		location = CLLocation(latitude: locationLat, longitude: locationLng)
		mapCoordinates = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
		mapKit.setRegion(mapCoordinates, animated: true)
	}
}
