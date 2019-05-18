//
//  Place.swift
//  PlacesNearMe
//
//  Created by Simeon Andreev on 14.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import Foundation

struct PlacesResponse: Codable {
	let results: [Place]
}
struct PlaceDetail: Codable {
	let result: Place
}

struct Place: Codable {
	let id: String
	let placeId: String
	let name: String
	let geometry: Geometry
	let formattedAddress: String?
	let openingHours: WeekdayTable?
	let rating: Float?
	let formattedPhoneNumber: String?
	let priceLevel: Float?
	let photos : [PhotoInfo]?
	
	enum CodingKeys: String, CodingKey {
		case id
		case placeId = "place_id"
		case name
		case geometry
		case formattedAddress = "formatted_address"
		case openingHours = "opening_hours"
		case rating
		case formattedPhoneNumber = "formatted_phone_number"
		case priceLevel = "price_level"
		case photos
	}
}

struct PhotoInfo : Codable {
	let height : Int
	let width : Int
	let photoReference : String
	enum CodingKeys : String, CodingKey {
		case height = "height"
		case width = "width"
		case photoReference = "photo_reference"
	}
}

struct Geometry: Codable {
	let location: Location
}
struct Location: Codable {
	let lat: Double
	let lng: Double
}
struct WeekdayTable: Codable {
	let weekdayText: [String]?
	
	enum CodingKeys: String, CodingKey {
		case weekdayText = "weekday_text"
	}
}
