//
//  UIVCExtensions.swift
//  Metaleon
//
//  Created by trilliwon on 07/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import UIKit

extension UIViewController {
    /// This alert controller's style is 'alert' and it has only one action which is 'OK' action
    func alert(title: String = "Notification",
               message: String,
               okTitle: String = "OK", okAction: (() -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: okTitle, style: .cancel) { _ in
                guard let action = okAction else { return }
                action()
            }

            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }

    /// This alert controller's style is 'alert' and it has two actions Which are 'OK' and 'CANCEL'
    func alert(title: String = "Notification",
               message: String,
               cancelTitle: String = "Cancel",
               okTitle: String, okAction: @escaping () -> Void) {

        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: okTitle, style: UIAlertAction.Style.default) { _ in okAction() }
            let cancelAction = UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.cancel)

            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }

    /// This alert controller's style is 'actionSheet'
    ///
    /// Make action list and use.
    ///
    ///         let actionSheetActions: [(title: String, action: ((UIAlertAction) -> Void))] =
    ///             [
    ///                 (title: "first action", action: { _ in
    ///                     print("This is frist action.")
    ///                 }),
    ///
    ///                 (title: "second action", action: { _ in
    ///                     print("This is second action.")
    ///                 }),
    ///
    ///                 (title: "third action", action: { _ in
    ///                     print("This is third action")
    ///                 })
    ///         ]
    ///       self.actionSheet(title: "example actionSheet extension", actions: actionSheetActions)
    ///
    func actionSheet(title: String = "Notification",
                     message: String? = nil,
                     cancelTitle: String? = "Cancel",
                     cancelStyle: UIAlertAction.Style = .cancel,
                     actions: [(title: String, action: ((UIAlertAction) -> Void))]) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach {
            alertController.addAction(UIAlertAction(title: $0.title, style: .default, handler: $0.action))
        }

        alertController.addAction(UIAlertAction(title: cancelTitle, style: cancelStyle, handler: { _ in
            alertController.dismiss(animated: true)
        }))

        self.present(alertController, animated: true)
    }
}
