//
//  AppDelegate.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        DataStore.initDefaults()
        
        let tintColor = #colorLiteral(red: 1, green: 0.4862745098, blue: 0.02102187648, alpha: 1)
        window?.tintColor = tintColor
        UIButton.appearance().tintColor = tintColor
        UISlider.appearance().tintColor = tintColor
        UINavigationBar.appearance().tintColor = tintColor
        
        DataStore.initDefaults()
        SKPaymentQueue.default().add(self)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if Library.status != .authorized {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let accessVC  = storyboard.instantiateViewController(withIdentifier: "AccessVC")
            self.window?.rootViewController?.present(accessVC, animated: true)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


// MARK: - Payment Transaction Observer
extension AppDelegate: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
                
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                let alert = UIAlertController(title: "Thank you for your purchase!",
                                              message: "You are amazing.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "👏", style: .cancel))
                window?.rootViewController?.present(alert, animated: true)
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                var details  = "Don't worry, everything's fine."
                if let error = transaction.error as? SKError {
                    switch error.code {
                    case .paymentCancelled:
                        break
                    case .unknown:
                        details = "Unknown error"
                    case .clientInvalid:
                        details = "You were not allowed to make this request."
                    case .paymentInvalid:
                        details = "The item you requested had an invalid identifier."
                    case .paymentNotAllowed:
                        details = "You were not allowed to pay for the request on this device."
                    case .storeProductNotAvailable:
                        details = "The product is not available anymore"
                    case .cloudServicePermissionDenied:
                        details = "You don't have access to the service."
                    case .cloudServiceNetworkConnectionFailed:
                        details = "Unable to contact the service."
                    case .cloudServiceRevoked:
                        details = "Your access has been revoked from the service."
                    }
                }
                let alert = UIAlertController(title: "Your purchase has been cancelled",
                                              message: details,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                window?.rootViewController?.present(alert, animated: true)
                
            case .restored, .purchasing, .deferred:
                break
            }
        }
    }
    
}
