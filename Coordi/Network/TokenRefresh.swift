//
//  TokenRefresh.swift
//  Coordi
//
//  Created by 차소민 on 4/16/24.
//

import Foundation
import Alamofire

final class TokenRefresh: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        guard urlRequest.url?.absoluteString.hasPrefix(BaseURL.baseURL.rawValue) == true,
              UserDefaultsManager.accessToken != "",
              UserDefaultsManager.refreshToken != ""
        else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        urlRequest.setValue(UserDefaultsManager.refreshToken, forHTTPHeaderField: HTTPHeader.refresh.rawValue)
        print("adator 적용 \(urlRequest.headers)")
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        do {
            print("!!!retry")
            let urlRequest = try Router.refreshToken.asURLRequest()
            guard let statusCode = request.response?.statusCode else { return }
            
            if statusCode == 419 {
                API.session.request(urlRequest)
                    .responseDecodable(of: AccessTokenModel.self) { response in
                        switch response.result {
                        case .success(let success):
                            print("토큰 갱신 성공 \(success)")
                            UserDefaultsManager.accessToken = success.accessToken
                            completion(.retry)
                        case .failure(_):
                            if let code = response.response?.statusCode {
                                print("❌토큰 갱신 실패: \(code)")
                                
                                // TODO: 418이면 최초 로그인 화면으로 돌려주기 (refreshToken도 만료)
                                //                            completion(.doNotRetryWithError(<#T##any Error#>))
                                if code == 418 {
                                    completion(.doNotRetryWithError(CoordiError.refreshTokenExpired))
                                } else {
                                    completion(.doNotRetry)
                                }
                            } else {
                                print("❌토큰 갱신 실패")
                                completion(.doNotRetry)
                            }
                        }
                    }
            } else {
                completion(.doNotRetry)
            }
        } catch {
            
        }
    }
    
}
