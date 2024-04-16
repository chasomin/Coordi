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
              let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        urlRequest.setValue(refreshToken, forHTTPHeaderField: HTTPHeader.refresh.rawValue)
        print("adator 적용 \(urlRequest.headers)")
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        do {
            let urlRequest = try Router.refreshToken.asURLRequest()
            
            AF.request(urlRequest)
                .responseDecodable(of: AccessTokenModel.self) { response in
                    switch response.result {
                    case .success(let success):
                        print("토큰 갱신 성공 \(success)")
                        UserDefaults.standard.set(success.accessToken, forKey: "accessToken")
                        completion(.retry)
                    case .failure(_):
                        if let code = response.response?.statusCode {
                            print("❌토큰 갱신 실패: \(code)")
                            // TODO: 418이면 최초 로그인 화면으로 돌려주기 (refreshToken도 만료)
                            completion(.doNotRetry)
                        } else {
                            print("❌토큰 갱신 실패")
                            completion(.doNotRetry)
                        }
                    }
                }
        } catch {
            
        }
    }
    
}
