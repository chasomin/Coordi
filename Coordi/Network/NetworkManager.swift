//
//  NetworkManager.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import Foundation
import Alamofire
import RxSwift

struct NetworkManager {
    static func request<T: Decodable>(api: Router) -> Single<T> {
        return Single<T>.create { single in
            do {
                let urlRequest = try api.asURLRequest()
                                
                AF.request(urlRequest, interceptor: TokenRefresh())
                    .responseDecodable(of: T.self) { response in
                        switch response.result {
                        case .success(let success):
                            single(.success(success))
                            dump(success)
                        case .failure(let error):
                            single(.failure(error))
                            print(error, response.response?.statusCode)
                        }
                    }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
