//
//  MovieService.swift
//  MovieInfo
//
//  Created by Alfian Losari on 10/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation

protocol PlaceService {
    
    func fetchPlaces(params: [String: String]?, successHandler: @escaping (_ response: PlacesResponse) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
    func fetchPlace(id: String, successHandler: @escaping (_ response: PlaceDetail) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
}


//public enum Endpoint: String, CustomStringConvertible, CaseIterable {
//    case nowPlaying = "now_playing"
//    case upcoming
//    case popular
//    case topRated = "top_rated"
//
//    public var description: String {
//        switch self {
//        case .nowPlaying: return "Now Playing"
//        case .upcoming: return "Upcoming"
//        case .popular: return "Popular"
//        case .topRated: return "Top Rated"
//        }
//    }
//
//    public init?(index: Int) {
//        switch index {
//        case 0: self = .nowPlaying
//        case 1: self = .popular
//        case 2: self = .upcoming
//        case 3: self = .topRated
//        default: return nil
//        }
//    }
//
//
//    public init?(description: String) {
//        guard let first = Endpoint.allCases.first(where: { $0.description == description }) else {
//            return nil
//        }
//        self = first
//    }
//
//}

public enum PlaceError: Error {
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
}
