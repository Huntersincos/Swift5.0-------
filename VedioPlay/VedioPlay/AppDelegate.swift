//
//  AppDelegate.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit


//@available(iOS 13.0, *) 工程用stroyboard搭建 简单界面用xlb 复杂界面用代码实现
// @UIApplicationMain 相当于oc的main函数
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var isForceLandscape:Bool = false
    var isForcePortrait:Bool = false
    var isForceAllDerictions:Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       // SDWebImageDownloader.initializeOnceMethod()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        let rootVC = window?.rootViewController
//        let presentedVC = rootVC?.presentedViewController
//        let supportedInterfaceOrientations = NSSelectorFromString("base_SupportedInterfaceOrientations")
//        if presentedVC?.isBeingDismissed ?? false{
//            if rootVC?.responds(to:supportedInterfaceOrientations) ?? false{
//                return rootVC?.base_SupportedInterfaceOrientations() ?? .portrait
//            }
//        }else{
//            if rootVC?.responds(to: supportedInterfaceOrientations) ?? false {
//                return presentedVC?.base_SupportedInterfaceOrientations() ?? .portrait
//            }
    //
//        }
        
       if isForceAllDerictions == true {
          return .all
       } else if isForceLandscape == true {
           return .landscape
       } else if isForcePortrait == true {
           return .portrait
       }
    
        return .portrait
    }
    
    


}

