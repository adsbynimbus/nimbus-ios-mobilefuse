//
//  MobileFuseInitializer.swift
//  NimbusMobileFuseKit
//  Created on 8/5/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import MobileFuseSDK
import NimbusKit

@MainActor
class MobileFuseInitializer: NSObject {
    
    enum State {
        case notInitialized, initializing, initialized
    }
    
    static let shared = MobileFuseInitializer()
    
    private var state: State = .notInitialized
    
    func initIfNeeded() {
        guard state == .notInitialized else { return }
        
        state = .initializing
        
        MobileFuse.initWithDelegate(self)
    }
}

extension MobileFuseInitializer: @preconcurrency IMFInitializationCallbackReceiver {
    func onInitSuccess(_ appId: String!, withPublisherId publisherId: String!) {
        Nimbus.Log.lifecycle.debug("MobileFuse SDK initialization completed")
        state = .initialized
    }
    
    func onInitError(
        _ appId: String!,
        withPublisherId publisherId: String!,
        withError error: MFAdError!
    ) {
        Nimbus.Log.lifecycle.error("Failed initializing MobileFuse with appId=\(String(describing: appId)), publisherId=\(String(describing: publisherId)), error: \(error.description)")
        state = .notInitialized
    }
}
