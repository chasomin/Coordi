//
//  NetworkManager.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import Foundation
import Alamofire
import RxSwift

class API {
    static let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        let apiLogger = APIMonitor()
        return Session(configuration: configuration, eventMonitors: [apiLogger])
    }()
}

struct NetworkManager {
    static func request<T: Decodable>(api: Router) -> Single<T> {
        return Single<T>.create { single in
            do {
                let urlRequest = try api.asURLRequest()
                
                API.session.request(urlRequest, interceptor: TokenRefresh())
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
    
    static func upload(api: Router, images: [Data]) -> Single<ImageUploadModel> {
        return Single<ImageUploadModel>.create { single in
            guard let url = URL(string: api.baseURL + api.path) else { return Disposables.create() }
            let accessToken = UserDefaultsManager.accessToken
            print(url)
            let headers: HTTPHeaders = [
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue,
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.authorization.rawValue: accessToken
            ]
            
            AF.upload(multipartFormData: { multipartFormData in
                for image in images {
                    multipartFormData.append(image,
                                             withName: "files",
                                             fileName: "Coordi.jpg",
                                             mimeType: "image/jpeg")
                }
                
            }, to: url, method: .post, headers: headers)
            .responseDecodable(of: ImageUploadModel.self) { response in
                switch response.result {
                case .success(let success):
                    single(.success(success))
                    dump(success)
                    
                case .failure(let error):
                    single(.failure(error))
                    print(error, response.response?.statusCode)
                }
            }
            return Disposables.create()
        }
    }
}
