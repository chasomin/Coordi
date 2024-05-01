//
//  Alert+.swift
//  Coordi
//
//  Created by 차소민 on 5/2/24.
//

import UIKit

extension BaseViewController {
    func showAlert(title: String, message: String, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .destructive) { _ in
            completionHandler()
        }

        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
}
