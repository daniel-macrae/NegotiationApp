//
//  AppDelegate.swift
//  Negotiation
//
//  Created by Mandy Slagter on 11/03/2023.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
