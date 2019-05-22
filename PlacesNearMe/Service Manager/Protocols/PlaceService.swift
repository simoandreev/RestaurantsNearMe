//
//  PlaceService.swift
//  PlacesNearMe
//
//  Created by Simeon Andreev on 14.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import Foundation

protocol PlaceService {
    
    func fetchPlaces(params: [String: String]?, successHandler: @escaping (_ response: PlacesResponse) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
    func fetchPlace(id: String, successHandler: @escaping (_ response: PlaceDetail) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
}

public enum PlaceError: Error {
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
}
