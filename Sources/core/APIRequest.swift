//
//  File.swift
//  
//
//  Created by Mason Phillips on 2/19/21.
//

import Foundation

public enum HTTPRequestMethod: String, CaseIterable {
    case GET, POST, PUT, DELETE, PATCH
    case HEAD, CONNECT, OPTIONS, TRACE
}

public enum AccessMethod: String, CaseIterable {
    case noAuth, apiKey, oauthToken
}

public protocol APIRequest {
    associatedtype Response: Decodable
    
    var accessMethod: AccessMethod { get }
    var endpoint    : String { get }
    var method      : HTTPRequestMethod { get }
    var headers     : Dictionary<String, String> { get }
    var params      : Dictionary<String, String> { get }
    
    var expectedResponseCode: Int? { get }
}
