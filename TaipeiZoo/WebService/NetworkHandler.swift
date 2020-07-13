//
//  File.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/22.
//  Copyright © 2020 Finn. All rights reserved.
//

import Foundation

class NetworkHandler {
    
    private var reachability: Reachability?
    
    static let shareInstance: NetworkHandler = {
        let instance = NetworkHandler()
        instance.setupReachability()
        return instance
    }()
    
    func isConnect() -> Bool {  // Check user have network or not
        
        guard let okReachability = reachability else { return false }
        
        if okReachability.currentReachabilityStatus().rawValue == 0 {
            return false
        } else {
            return true
        }
    }
    
    private func setupReachability()  {
        
        reachability = Reachability.forInternetConnection()
        guard let okReachability = reachability else { return }
        okReachability.startNotifier()
    }
}
