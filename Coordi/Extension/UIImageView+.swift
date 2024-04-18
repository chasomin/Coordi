//
//  UIImageView+.swift
//  Coordi
//
//  Created by 차소민 on 4/18/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(from url: URL, placeHolderImage: UIImage? = nil) {
        let modifier = AnyModifier { request in
            var request = request
            request.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            request.setValue(APIKey.key.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
            return request
        }
        self.kf.setImage(with: url, placeholder: placeHolderImage, options: [.requestModifier(modifier), .forceRefresh])
    }
}
