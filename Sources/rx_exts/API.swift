//
//  File.swift
//  
//
//  Created by Mason Phillips on 2/19/21.
//

import Foundation
import core
import RxSwift

public extension API {
    func request<T: APIRequest>(_ request: T) throws -> Single<T.Response> {
        let urlRequest = try self.build(request)
        
        return Single.create { [session, decoder] observer -> Disposable in
            let task = session.dataTask(with: urlRequest) { [decoder] data, response, error in
                do {
                    guard let response = response as? HTTPURLResponse else { throw APIError.unexpectedResponse }
                    if let code = request.expectedResponseCode {
                        guard code == response.statusCode else { throw APIError.unexpectedResponseCode(expected: code, received: response.statusCode) }
                    }
                    
                    if let data = data {
                        let json = try decoder.decode(T.Response.self, from: data)
                        observer(.success(json))
                    }
                    else if let error = error { observer(.failure(error)) }
                    else { throw APIError.noResponse }
                } catch {
                    observer(.failure(error))
                }
            }
            
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
