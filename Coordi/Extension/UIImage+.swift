//
//  UIImage+.swift
//  Coordi
//
//  Created by 차소민 on 4/19/24.
//

import UIKit

extension UIImage {
    var compressedJPEGData: Data? {
        let maxQuality: CGFloat = 1.0
        let minQuality: CGFloat = 0.0
        let maxSizeInBytes = 3.0 * 1024 * 1024
        
        // 최대 품질(무압축)에서 시작
        var compressionQuality: CGFloat = maxQuality
        
        // 이미지를 JPEG 데이터로 변환
        guard var compressedData = self.jpegData(compressionQuality: compressionQuality) else { return nil }
        
        
        /// 용량이 최대 기준치 이하가 되었거나, 압축률이 100%가 아니면 반복 수행
        while Double(compressedData.count) > maxSizeInBytes && compressionQuality > minQuality {
            // 압축률 10% 증가 후 다시 시도
            compressionQuality -= 0.1
            
            guard let newData = self.jpegData(compressionQuality: compressionQuality) else { break }
            compressedData = newData
        }
        
        return compressedData
    }
}

extension UIImage {
    func setConfiguration(font: UIFont) -> UIImage {
        let config = Self.SymbolConfiguration(font: font)
        return self.withConfiguration(config)
    }
}


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
