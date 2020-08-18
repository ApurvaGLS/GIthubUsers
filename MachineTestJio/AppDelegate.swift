//
//  AppDelegate.swift
//  MachineTestJio
//
//  Created by Apurva Dongre on 17/08/20.
//  Copyright © 2020 Apurva Dongre. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
     var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          self.window = UIWindow(frame: UIScreen.main.bounds)
          let myVC = ViewController()
          let navCon = UINavigationController(rootViewController: myVC)
          self.window!.rootViewController = navCon
          self.window?.makeKeyAndVisible()
          return true
    }
}

