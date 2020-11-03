
import Foundation
import OAuthSwift
import RxSwift

open class API {
    public let oauth  : OAuthSwift!
    public let baseURL: URL
    
    private let decoder: JSONDecoder = JSONDecoder()
    private let session: URLSession  = URLSession(configuration: .background(withIdentifier: "api-common-session"))
    
    public enum APIError: Error {
        case unknownAPIError
        case noResponse
        case unexpectedHTTPCode(_ code: Int)
        case missingTokenOrSecret
    }
    
    public init(_ baseURL: URL, oauth: OAuthSwift? = nil) {
        self.baseURL = baseURL
        self.oauth = oauth
    }
    
    open func buildURLRequest<T: APIRequestType>(_ request: T) -> URLRequest {
        return URLRequest(url: self.baseURL.appendingPathComponent(request.endpoint))
    }
    
    public func fetch<T: APIRequestType>(_ request: T, completion: @escaping (_ data: T.Response?, _ error: Error?) -> Void) {
        switch request.level {
        case .oauthToken: return self.fetchOAuth(request, completion: completion)
        default: return self.fetchAPIKey(request, completion: completion)
        }
    }
    public func fetch<T: APIRequestType>(_ request: T) -> Single<T.Response> {
        switch request.level {
        case .oauthToken: return self.fetchOAuth(request)
        default: return self.fetchAPIKey(request)
        }
    }
    
    internal func fetchOAuth<T: APIRequestType>(_ request: T) -> Single<T.Response> {
        return Single.create { [unowned decoder] observer in
            let url = self.baseURL.appendingPathComponent(request.endpoint)
            let task = self.oauth.client.get(url, parameters: request.params, headers: request.headers) { [unowned decoder] result in
                switch result {
                case .failure(let error): observer(.error(error))
                case .success(let response):
                    do {
                        guard response.response.statusCode == request.expect else {
                            throw APIError.unexpectedHTTPCode(response.response.statusCode)
                        }
                        
                        let data = try decoder.decode(T.Response.self, from: response.data)
                        observer(.success(data))
                    } catch {
                        observer(.error(error))
                    }
                }
            }

            return Disposables.create {
                task?.cancel()
            }
        }
    }
    internal func fetchOAuth<T: APIRequestType>(_ request: T, completion: @escaping (_ data: T.Response?, _ error: Error?) -> Void) {
        let url = baseURL.appendingPathComponent(request.endpoint)
        let _ = self.oauth.client.get(url, parameters: request.params, headers: request.headers) { [unowned decoder] result in
            switch result {
            case .failure(let error): completion(nil, error)
            case .success(let response):
                do {
                    guard response.response.statusCode == request.expect else {
                        throw APIError.unexpectedHTTPCode(response.response.statusCode)
                    }
                    
                    let data = try decoder.decode(T.Response.self, from: response.data)
                    completion(data, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
        
        
    }
    
    internal func fetchAPIKey<T: APIRequestType>(_ request: T) -> Single<T.Response> {
        return Single.create { [unowned decoder, unowned session] observer in
            let urlRequest = self.buildURLRequest(request)
            let task = session.dataTask(with: urlRequest) { [unowned decoder] data, response, error in
                do {
                    guard let response = response as? HTTPURLResponse else {
                        throw APIError.noResponse
                    }
                    
                    guard response.statusCode == request.expect else {
                        throw APIError.unexpectedHTTPCode(response.statusCode)
                    }
                    
                    if let data = data {
                        let result = try decoder.decode(T.Response.self, from: data)
                        observer(.success(result))
                    } else if let error = error {
                        observer(.error(error))
                    } else {
                        throw APIError.unknownAPIError
                    }
                } catch {
                    observer(.error(error))
                }
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
    internal func fetchAPIKey<T: APIRequestType>(_ request: T, completion: @escaping (_ data: T.Response?, _ error: Error?) -> Void) {
        let urlRequest = buildURLRequest(request)
        let task = session.dataTask(with: urlRequest) { [unowned decoder] data, response, error in
            do {
                guard let response = response as? HTTPURLResponse else {
                    throw APIError.noResponse
                }
                
                guard response.statusCode == request.expect else {
                    throw APIError.unexpectedHTTPCode(response.statusCode)
                }
                
                if let data = data {
                    let result = try decoder.decode(T.Response.self, from: data)
                    completion(result, nil)
                } else if let error = error {
                    completion(nil, error)
                } else {
                    throw APIError.unknownAPIError
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
