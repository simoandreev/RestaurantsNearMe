//
//  MovieRepository.swift
//  MovieKit
//
//  Created by Alfian Losari on 11/24/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import Foundation

public class PlaceServiceManager: PlaceService {
    
    public static let shared = PlaceServiceManager()
    private init() {}
	let apiKey = "AIzaSyCXE7t8i9WoAWAwcPl-9yilj7m545tpXbA"
	let baseAPIURL = "https://maps.googleapis.com/maps/api/place/"
    private let urlSession = URLSession.shared
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
	
        return jsonDecoder
    }()
    
    
	func fetchPlaces(params: [String: String]? = nil, successHandler: @escaping (_ response: PlacesResponse) -> Void, errorHandler: @escaping(_ error: Error) -> Void) {
        
        guard var urlComponents = URLComponents(string: "\(baseAPIURL)nearbysearch/json") else {
            errorHandler(PlaceError.invalidEndpoint)
            return
        }
        
        var queryItems = [URLQueryItem(name: "key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            errorHandler(PlaceError.invalidEndpoint)
            return
        }
        
        urlSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.handleError(errorHandler: errorHandler, error: PlaceError.apiError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.handleError(errorHandler: errorHandler, error: PlaceError.invalidResponse)
                return
            }
            
            guard let data = data else {
                self.handleError(errorHandler: errorHandler, error: PlaceError.noData)
                return
            }
            
            do {
                let placesResponse = try self.jsonDecoder.decode(PlacesResponse.self, from: data)
                DispatchQueue.main.async {
                    successHandler(placesResponse)
                }
            } catch {
                self.handleError(errorHandler: errorHandler, error: PlaceError.serializationError)
            }
        }.resume()
        
    }
    
    
	func fetchPlace(id: String, successHandler: @escaping (_ response: PlaceDetail) -> Void, errorHandler: @escaping(_ error: Error) -> Void) {
        guard let url = URL(string: "\(baseAPIURL)details/json?placeid=\(id)&key=\(apiKey)") else {
            handleError(errorHandler: errorHandler, error: PlaceError.invalidEndpoint)
            return
        }
        
        urlSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.handleError(errorHandler: errorHandler, error: PlaceError.apiError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.handleError(errorHandler: errorHandler, error: PlaceError.invalidResponse)

                return
            }
            
            guard let data = data else {
                self.handleError(errorHandler: errorHandler, error: PlaceError.noData)
                return
            }
            do {
				let place = try self.jsonDecoder.decode(PlaceDetail.self, from: data)
                DispatchQueue.main.async {
                    successHandler(place)
                }
            } catch {
                self.handleError(errorHandler: errorHandler, error: PlaceError.serializationError)
            }
        }.resume()
    
    }
    
    private func handleError(errorHandler: @escaping(_ error: Error) -> Void, error: Error) {
        DispatchQueue.main.async {
            errorHandler(error)
        }
    }
    
}
