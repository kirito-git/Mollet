//
//  ReachabilityManager.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/11/1.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//

import UIKit
import Reachability

class ReachabilityManager {
    
    class func netWorkCheck() {
        
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            MBProgressHUDSwift.showError("Please check your internet")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
}
