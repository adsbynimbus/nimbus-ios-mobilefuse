//
//  MobileFuseRequestBridge.swift
//  Nimbus
//  Created on 3/10/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import MobileFuseSDK
import NimbusKit

protocol MobileFuseRequestBridgeType: Sendable {
    func tokenData() async throws -> [String: String]
}

final class MobileFuseRequestBridge: MobileFuseRequestBridgeType {
    public init() {}
    
    @inlinable
    public static func set(coppa: Bool) {
        let preferences: MobileFusePrivacyPreferences = MobileFuse.getPrivacyPreferences() ?? MobileFusePrivacyPreferences()
        preferences.setSubjectToCoppa(coppa)
        MobileFuse.setPrivacyPreferences(preferences)
    }
    
    public func tokenData() async throws -> [String: String] {
        let tokenRequest = MFBiddingTokenRequest()
        tokenRequest.partner = .MOBILEFUSE_PARTNER_NIMBUS
        
        let tokenData = await withUnsafeContinuation { continuation in
            MFBiddingTokenProvider.getTokenData(with: tokenRequest) { data in
                continuation.resume(returning: data)
            }
        }
        
        if let error = tokenData["error"] {
            throw NimbusError.mobileFuse(stage: .request, detail: "Couldn't fetch token data: \(error)")
        }
        
        return tokenData
    }
}
