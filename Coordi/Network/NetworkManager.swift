//
//  NetworkManager.swift
//  Coordi
//
//  Created by 차소민 on 4/15/24.
//

import Foundation
import Alamofire
import RxSwift

final class API {
    static let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        let apiLogger = APIMonitor.shared
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
                        case .failure(_):
                            print("👻여기!@!@!@")
                            guard let statusCode = response.response?.statusCode else { return }
                            switch statusCode {
                            case 400:
                                single(.failure(CoordiError.invalidRequest(kind: api)))
                            case 401:
                                single(.failure(CoordiError.unauthenticatedToken(kind: api)))
                            case 403:
                                single(.failure(CoordiError.forbidden))
                            case 409:
                                single(.failure(CoordiError.alreadySubscribed))
                            case 410:
                                single(.failure(CoordiError.creationFailed))
                            case 418:
                                single(.failure(CoordiError.refreshTokenExpired))
                            case 419:
                                single(.failure(CoordiError.accessTokenExpired))
                            case 420:
                                single(.failure(CoordiError.withoutKey))
                            case 429:
                                single(.failure(CoordiError.overCall))
                            case 444:
                                single(.failure(CoordiError.invalidURL))
                            case 445:
                                single(.failure(CoordiError.haveNoAuthority))
                            case 500:
                                single(.failure(CoordiError.unknownError))
                            default:
                                single(.failure(CoordiError.unknownError))
                            }
                            print("👻여기!@!@!@", statusCode)

                        }
                    }
            } catch {
            }
            return Disposables.create()
        }
    }
    
    static func request(api: Router) -> Single<Bool> {
        return Single<Bool>.create { single in
            do {
                let urlRequest = try api.asURLRequest()
                
                API.session.request(urlRequest, interceptor: TokenRefresh())
                    .response(completionHandler: { response in
                        switch response.result {
                        case .success(_):
                            single(.success(true))
                        case .failure(_):
                            print("👻여기!@!@!@")
                            guard let statusCode = response.response?.statusCode else { return }
                            switch statusCode {
                            case 400:
                                single(.failure(CoordiError.invalidRequest(kind: api)))
                            case 401:
                                single(.failure(CoordiError.unauthenticatedToken(kind: api)))
                            case 403:
                                single(.failure(CoordiError.forbidden))
                            case 409:
                                single(.failure(CoordiError.alreadySubscribed))
                            case 410:
                                single(.failure(CoordiError.creationFailed))
                            case 418:
                                single(.failure(CoordiError.refreshTokenExpired))
                            case 419:
                                single(.failure(CoordiError.accessTokenExpired))
                            case 420:
                                single(.failure(CoordiError.withoutKey))
                            case 429:
                                single(.failure(CoordiError.overCall))
                            case 444:
                                single(.failure(CoordiError.invalidURL))
                            case 445:
                                single(.failure(CoordiError.haveNoAuthority))
                            case 500:
                                single(.failure(CoordiError.unknownError))
                            default:
                                single(.failure(CoordiError.unknownError))
                            }
                            print("👻여기!@!@!@", statusCode)

                        }
                    })
            } catch {
            }
            return Disposables.create()
        }
    }

    static func upload<T: Decodable>(api: Router) -> Single<T> {
        return Single<T>.create { single in
            guard let url = URL(string: api.baseURL + api.path) else { return Disposables.create() }
            let accessToken = UserDefaultsManager.accessToken
            print(url)
            let headers: HTTPHeaders = [
                HTTPHeader.sesacKey.rawValue: APIKey.key.rawValue,
                HTTPHeader.contentType.rawValue: HTTPHeader.multi.rawValue,
                HTTPHeader.authorization.rawValue: accessToken
            ]
            guard let parameters = api.parameters else { return Disposables.create() }
            
            API.session.upload(multipartFormData: { multipartFormData in
                
                for (key, value) in parameters {
                    if value is [Data] {
                        for image in value as! [Data] {
                            multipartFormData.append(image,
                                                     withName: key,
                                                     fileName: "Coordi.jpg",
                                                     mimeType: "image/jpeg")
                        }
                    } else if value is Data {
                        multipartFormData.append(value as! Data,
                                                 withName: key,
                                                 fileName: "Coordi.jpg",
                                                 mimeType: "image/jpeg")
                    } else {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }
                
            }, to: url, method: api.method, headers: headers)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let success):
                    single(.success(success))
                    dump(success)
                    
                case .failure(_):
                    guard let statusCode = response.response?.statusCode else { return }
                    switch statusCode {
                    case 400:
                        single(.failure(CoordiError.invalidRequest(kind: api)))
                    case 401:
                        single(.failure(CoordiError.unauthenticatedToken(kind: api)))
                    case 403:
                        single(.failure(CoordiError.forbidden))
                    case 409:
                        single(.failure(CoordiError.alreadySubscribed))
                    case 410:
                        single(.failure(CoordiError.creationFailed))
                    case 418:
                        single(.failure(CoordiError.refreshTokenExpired))
                    case 419:
                        single(.failure(CoordiError.accessTokenExpired))
                    case 420:
                        single(.failure(CoordiError.withoutKey))
                    case 429:
                        single(.failure(CoordiError.overCall))
                    case 444:
                        single(.failure(CoordiError.invalidURL))
                    case 445:
                        single(.failure(CoordiError.haveNoAuthority))
                    case 500:
                        single(.failure(CoordiError.unknownError))
                    default:
                        single(.failure(CoordiError.unknownError))
                    }
                }
            }
            return Disposables.create()
        }
    }
}


enum CoordiError: Error {
    case withoutKey
    case invalidRequest(kind: Router)
    case unauthenticatedToken(kind: Router)
    case forbidden
    case alreadySubscribed
    case creationFailed
    case refreshTokenExpired
    case accessTokenExpired
    case overCall
    case invalidURL
    case haveNoAuthority
    case unknownError
    
    var errorMessage: String {
        switch self {
        case .withoutKey:                       // 420
            "SeSAC Memolease Only"
        case .invalidRequest(let kind):         // 400
            switch kind {
            case .signUp, .emailValidation, .logIn:
                "필수 값을 채워주세요"
            case .uploadImage, .editProfileImage:
                "5MB 미만 이미지만 가능해요"
            case .uploadComment, .editComment:
                "댓글 내용을 채워주세요"
            case .like, .follow, .hashtag, .fetchPost, .fetchParticularPost, .fetchPostByUser, .fetchLikePost:
                "잘못된 요청이에요"
            case .paymentValid:
                "유효하지 않은 결제건입니다"
            default:
                ""
            }
        case .unauthenticatedToken(let kind):   // 401
            switch kind {
            case .logIn:
                "계정을 확인해주세요"
            default:
                "다시 로그인해주세요"
            }
        case .forbidden:                        // 403
            "접근권한이 없어요"
        case .alreadySubscribed:                // 409
            "이미 가입된 계정이에요"
        case .creationFailed:                   // 410, 저장수정삭제
            "생성 실패"
        case .refreshTokenExpired:              // 418
            "다시 로그인해주세요"
        case .accessTokenExpired:               // 419
            "accessToken 만료"
        case .overCall:                         // 429
            "잠시후에 다시 시도해주세요"
        case .invalidURL:                       // 444
            "비정상 URL"
        case .haveNoAuthority:                  // 445
            "다른 사용자 글은 접근권한이 없어요"
        case .unknownError:                     // 500
            "오류가 발생했어요"
        }
    }
}
