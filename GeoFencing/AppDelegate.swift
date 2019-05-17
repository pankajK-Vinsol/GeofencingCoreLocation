//
//  AppDelegate.swift
//  GeoFencing
//
//  Created by Pankaj kumar on 03/05/19.
//  Copyright © 2019 Pankaj kumar. All rights reserved.
//

import UIKit
import CoreLocation
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: geofencing handler functions 
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    private func handleEvent(for region: CLRegion!) {
        if UIApplication.shared.applicationState == .active {
            guard let message = note(from: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        }
    }
    
    private func note(from identifier: String) -> String? {
        let regions = RegionData.allRegions()
        guard let matched = regions.first(where: { $0.identifier == identifier  }) else {
            return nil
        }
        let alertMessage = "\(String(describing: matched.subtitle)) from \(String(describing: matched.title))"
        return alertMessage
    }

}
