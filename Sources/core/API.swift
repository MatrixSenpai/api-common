//
//  File.swift
//  
//
//  Created by Mason Phillips on 2/19/21.
//

import Foundation

open class API {
    public let baseURL: URL
    public let decoder: JSONDecoder
    public let session: URLSession
    
    init(base url: URL, dateStrategy: JSONDecoder.DateDecodingStrategy) {
        self.baseURL = url
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = dateStrategy
        
        self.session = URLSession.shared
    }
    
    open func build<T: APIRequest>(_ request: T) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(request.endpoint)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw APIError.buildComponents }
        
        if request.method == .GET && !request.params.isEmpty {
            components.queryItems = request.params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let componentsURL = components.url else { throw APIError.buildComponentsUrl }
        
        var urlRequest = URLRequest(url: componentsURL)
        urlRequest.httpMethod = request.method.rawValue
        
        for header in request.headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return urlRequest
    }
    
    public func request<T: APIRequest>(_ request: T, completion: @escaping ((T.Response?, Error?) -> Void)) throws {
        let urlRequest = try self.build(request)
        
        let task = session.dataTask(with: urlRequest) { [decoder] data, response, error in
            do {
                guard let response = response as? HTTPURLResponse else { throw APIError.unexpectedResponse }
                if let code = request.expectedResponseCode {
                    guard code == response.statusCode else { throw APIError.unexpectedResponseCode(expected: code, received: response.statusCode) }
                }
                
                if let data = data {
                    let json = try decoder.decode(T.Response.self, from: data)
                    completion(json, nil)
                }
                else if let error = error { completion(nil, error) }
                else { throw APIError.noResponse }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    public enum APIError: Error {
        case buildComponents, buildComponentsUrl
        case noResponse, unexpectedResponse
        case unexpectedResponseCode(expected: Int, received: Int)
    }
}
