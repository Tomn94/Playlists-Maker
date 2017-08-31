//
//  AppDelegate.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tintColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1921568627, alpha: 1)
        window?.tintColor = tintColor
        UIButton.appearance().tintColor = tintColor
        UISlider.appearance().tintColor = tintColor
        UINavigationBar.appearance().tintColor = tintColor
        
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

