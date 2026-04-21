//
//  NimbusMobileFuseRequestInterceptor.swift
//  NimbusMobileFuseKit
//  Created on 8/2/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusKit
import MobileFuseSDK

final class NimbusMobileFuseRequestInterceptor: Sendable {
    /// Bridge that communicates with MobileFuse SDK
    private let bridge: MobileFuseRequestBridgeType
    
    public convenience init() {
        self.init(bridge: MobileFuseRequestBridge())
    }
    
    init(bridge: MobileFuseRequestBridgeType) {
        self.bridge = bridge
    }
}

extension NimbusMobileFuseRequestInterceptor: NimbusRequest.Interceptor {
    func modifyRequest(request: NimbusRequest) async throws -> [NimbusRequest.Delta] {
        let tokenData = try await bridge.tokenData()
        try Task.checkCancellation()
                
        return [.init(target: .user, key: "mfx_buyerdata", value: tokenData)]
    }
}
