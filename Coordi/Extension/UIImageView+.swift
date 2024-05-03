//
//  UIImageView+.swift
//  Coordi
//
//  Created by 차소민 on 4/18/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(from path: String, placeHolderImage: UIImage? = nil) {
        guard let url = URL(string: BaseURL.baseURL.rawValue + BaseURL.version.rawValue + "/" + path) else { return }
        let modifier = AnyModifier { request in
            var request = request
            request.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            request.setValue(APIKey.key.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
            return request
        }
        self.kf.setImage(with: url, placeholder: placeHolderImage, options: [.requestModifier(modifier), .forceRefresh]) { result in
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
