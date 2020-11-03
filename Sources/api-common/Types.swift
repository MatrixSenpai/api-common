//
//  File.swift
//  
//
//  Created by Mason Phillips on 11/2/20.
//

import Foundation

public enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

public enum AccessLevel {
    case open, apiKey, oauthToken
}

public protocol APIRequestType {
    associatedtype Response: APIResponseType
    
    var endpoint: String           { get }
    var method  : HTTPMethod       { get }
    var params  : [String: String] { get }
    var headers : [String: String] { get }
    var level   : AccessLevel      { get }
    var expect  : Int              { get }
}

public protocol APIResponseType: Decodable {}
