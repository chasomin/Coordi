<img src="https://github.com/chasomin/Coordi/assets/114223423/0ce875af-7330-40a9-878e-7443d1578769" width=100, height=100>

# ℃OORDI

현재 기온에 맞는 옷 스타일을 공유하고 아이템을 구매할 수 있는 앱

### iOS 1인 개발 
(서버 개발자 협업)


### **기간**

24.04.12 ~ 24.05.05 (3주)

업데이트 진행 중

### **최소버전**

iOS 16.0


### **스크린샷**

<img src="https://www.notion.so/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2Fcc0ffd51-4ef9-4d9a-93db-32e97a65a422%2F30cb5913-e1a2-4fe9-8023-5a54b4932fa9%2F%25E1%2584%2586%25E1%2585%25AE%25E1%2584%258C%25E1%2585%25A6_8.001.png?table=block&id=80909fbe-80b0-426c-b514-4cd35f13e810&spaceId=cc0ffd51-4ef9-4d9a-93db-32e97a65a422&width=2000&userId=b94327c2-0d8a-417c-b55a-6222a7f4ecb6&cache=v2" >
<img src="https://www.notion.so/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2Fcc0ffd51-4ef9-4d9a-93db-32e97a65a422%2F1c9c328f-f797-4452-b53e-b4c8c4f6af74%2F4.001.png?table=block&id=0c935845-f583-450b-a3ca-7e7bb01d6579&spaceId=cc0ffd51-4ef9-4d9a-93db-32e97a65a422&width=2000&userId=b94327c2-0d8a-417c-b55a-6222a7f4ecb6&cache=v2">
<br>

## 기능 소개

- 현재 기온에 맞는 팔로잉 / 전체 사용자의 스타일 피드를 추천
- 코디 참고하고 싶은 날씨 기온 검색 기능
- 나의 스타일 공유 기능
- 댓글 좋아요 기능
- 스타일 아이템 장바구니, 구매 기능

## **기술**

`UIKit` `MVVM-C` `RxSwift` `DependencyInjection` `WeatherKit` `CoreLocation` `Alamofire` `Codable` `Router` `URLRequestConvertible` `interceptor` `EventMonitor` `CodeBaseUI` `SnapKit` `CompositionalLayout` `DiffableDataSource` `UserDefaults` `Toast` `IQKeyboardManager` `Kingfisher` `Tabman`

## **기술 고려 사항**
 네비게이션 로직을 분리하여 코드의 모듈화와 유지보수성을 높이기 위해 Coordinator 패턴 적용
 
 반응형 프로그래밍을 하기 위해 RxSwif 사용
 
 객체 간의 결합도를 낮추고 유연성을 높이기 위해 Dependency Injection 구현

## **기술 설명**
 
 **URLRequestConvertible** protocol을 채택한 **Router**를 구현하여 API 요청 로직을 캡슐화

 Alamofire **interceptor**를 통해 토큰 갱신 자동화

 Alamofire **EventMonitor**를 사용한 디버깅으로 네트워크 문제를 해결

 **Coordinator** **패턴**을 사용하여 단일 책임 원칙을 준수하고 각 컴포넌트 간의 의존성 감소

 **Dependency Injection** 을 통해 Testable 한 코드 작성, 각 컴포넌트 간의 의존성 감소

 **MVVM Input-Output 패턴**을 사용하여 비즈니스 로직 분리

 **Compositional Layout**을 통해 Section 별 다양한 Cell을 구성

 **DiffableDataSource**를 사용하여 snapshot을 관리하고 이를 통해 효율적인 뷰 구성

 **BaseView**를 통해 일관된 ViewController 구조 형성

 **StatusCode** 관리로 에러 상황 별 다른 에러 처리

 **PropertyWrapper** 를 사용하여 반복되는 코드 개선

 **Final** 키워드와 **접근제어자**를 사용하여 컴파일 최적화 달성하기 위해 노력

 **weak self** 키워드를 사용하여 메모리 누수 방지

 protocol 생성 시 **AnyObject** 채택을 통해 해당 protocol을 채택할 수 있는 객체의 타입을 제한하여 메모리 누수 방지

 num **NameSpace**를 통해 literal 값을 캡슐화하여 유지보수에 용이한 코드 구현

## 트러블슈팅

1️⃣ 이미지로 인한 메모리 부족으로 앱이 강제 종료되는 문제
width를 받아 비율로 이미지를 resize하는 메서드를 구현하고, kingfisher로 setImage를 할 때, resize 메서드를 호출하여 메모리 문제를 해결

```swift
extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
}
extension UIImageView {
    func loadImage(from path: String, placeHolderImage: UIImage? = nil) {
        guard let url = URL(string: BaseURL.baseURL.rawValue + BaseURL.version.rawValue + "/" + path) else { return }
        let modifier = AnyModifier { request in
            var request = request
            request.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            request.setValue(APIKey.key.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
            return request
        }
        self.kf.setImage(with: url, placeholder: placeHolderImage, options: [.requestModifier(modifier)]) { result in
            switch result {
            case .success(let imageResult):
                let resizedImage = imageResult.image.resize(newWidth: 150)
                self.image = resizedImage
                self.isHidden = false
            case .failure(_):
                self.image = UIImage.emptyProfile
                self.isHidden = false
            }
        }
    }
}
```
<img src="https://github.com/chasomin/Coordi/assets/114223423/6cd13ae9-57f2-4d69-a808-dc404c1f1313" >

