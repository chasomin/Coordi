//
//  APIMonitor.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//
import Alamofire
import Foundation

final class APIMonitor: EventMonitor {
    
    static let shared = APIMonitor()
    private init() { }
    
    // 요청 시작
    func requestDidResume(_ request: Request) {
        guard let request = request.request?.urlRequest else { return }
        var body: String = "body 없음"
        if let httpBody = request.httpBody {
            body = toPrettyJsonString(data: httpBody)
        }
        
        let message =  """
✅ 요청시작

[📍요청 URL]
\(request.url?.absoluteString ?? "URL 확인 불가")

[📍요청 메서드]
\(request.method?.rawValue ?? "HTTP 메서드 확인 불가")

[📍요청 헤더]
\(request.headers.dictionary.description)

[📍요청 바디]
\(body)

---
"""
        print(message)
    }
    
    // URLRequest 생성 -> 네트워크 요청 시작 직전
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) { }
    
    // URLSessionTask 생성 직후
    // 세션 작업 추적 혹은 관련 데이터 로깅
    func request(_ request: Request, didCreateTask task: URLSessionTask) { }
    
    // 요청 작업 성공 혹은 취소 시점
    func requestDidFinish(_ request: Request) { }
    
    // 요청 후 응답 완료
    // 성공 여부에 상관없이 호출
    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
        guard let httpResponse = task.response as? HTTPURLResponse else {
            return
        }
        
        let message = """
✅ 응답 완료

[📍상태코드]
\(httpResponse.statusCode)

[📍헤더정보]
\(httpResponse.headers.description)

---
"""
        print(message)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        
        guard let error = response.error, let data = response.data else { return }
        
        let message = """
⚠️ 파싱 에러
[📍에러 메세지]
\(error)

[📍응답 Json]
\(toPrettyJsonString(data: data))
"""
        print(message)
    }
    
    func toPrettyJsonString(data: Data) -> String {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else {
            return "-"
        }
        
        return prettyString
    }
}
