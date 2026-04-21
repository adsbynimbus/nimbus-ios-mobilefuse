//
//  NimbusMobileFuseRequestModifierTests.swift
//  NimbusMobileFuseKitTests
//
//  Created on 9/12/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@testable import NimbusMobileFuseKit
@testable import NimbusKit
import Testing

@Suite("MobileFuse request interceptor tests") struct NimbusMobileFuseRequestInterceptorTests {
    let interceptor = NimbusMobileFuseRequestInterceptor(
        bridge: MockRequestBridge({ Self.mobileFuseData })
    )
    
    static let mobileFuseData: [String: String] = [
        "mf_adapter": "nimbus",
        "eid_source": "000",
        "sdk_version": "1.7.3",
        "v": "2"
    ]
    
    @Test func insertMobileFuseTokenData() async throws {
        let info = try NimbusRequest(from: await Nimbus.bannerAd(position: "test", size: .banner).adRequest!.request)
        let deltas = try await self.interceptor.modifyRequest(request: info)
        
        #expect(deltas.count == 1)
        #expect(deltas[0].target == .user)
        #expect(deltas[0].key == "mfx_buyerdata")
        #expect(deltas[0].value as? [String: String] == Self.mobileFuseData)
    }
    
    @Test func mobileFuseTokenDataGetsInsertedIntoRequest() async throws {
        var request = try await Nimbus.bannerAd(position: "position", size: .banner).adRequest!.request
        request.interceptors = []
        request.interceptors.append(interceptor)
        try await request.modifyRequestWithExtras(
            configuration: Nimbus.configuration,
            vendorId: "",
            appVersion: "1.0.0"
        )
        
        #expect(request.user?.ext?.extras["mfx_buyerdata"] as? [String: String] == Self.mobileFuseData)
    }
}

private final class MockRequestBridge: MobileFuseRequestBridgeType {
    let onTokenData: (@Sendable () async throws -> [String: String])
    
    init(_ onTokenData: @escaping @Sendable () async throws -> [String: String]) {
        self.onTokenData = onTokenData
    }
    
    func tokenData() async throws -> [String : String] {
        try await onTokenData()
    }
}
