//
//  TargetType.swift
//  Coordi
//
//  Created by 차소민 on 4/14/24.
//

import Foundation
import Alamofire

protocol TargetType: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var header: [String:String] { get }
    var parameters: [String:Any]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}

extension TargetType {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
        urlRequest.allHTTPHeaderFields = header
        
        if let parameters = parameters {
            if method == .get {
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
            } else {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
}
