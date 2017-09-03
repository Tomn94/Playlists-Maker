//
//  AccessVC.swift
//  Playlist Maker
//
//  Created by Tomn on 31/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// Modal view blocking app if user doesn't give access to their Music Library.
/// Contains a button to allow access.
class AccessVC: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Library.status == .authorized {
            authorized()
        }
    }
    
    /// Called when user has granted access
    func authorized() {
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .libraryAccessGranted, object: nil)
            self.dismiss(animated: true)
        }
    }
    
    /// User tapped Request Access button,
    /// Or has answered to iOS request alert
    @IBAction func allow() {
        
        switch Library.status {
            
        case .notDetermined:
            Library.askAuthorization { _ in
                self.allow()
            }
            
        case .denied, .restricted:
            // User denied access
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Music Access Denied",
                                              message: "Do you want to change this in Settings?",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                let confirmAction = UIAlertAction(title: "Authorize", style: .default) { _ in
                    
                    // Open iOS Settings
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!,
                                              options: [:])
                }
                alert.addAction(confirmAction)
                alert.preferredAction = confirmAction
                self.present(alert, animated: true)
            }
            
        case .authorized:
            // User shares access, dismiss this Request view
            authorized()
        }
    }
    
}
