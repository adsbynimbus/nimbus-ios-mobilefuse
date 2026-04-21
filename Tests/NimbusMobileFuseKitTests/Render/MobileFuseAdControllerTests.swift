//
//  MobileFuseAdControllerTests.swift
//  NimbusMobileFuseKitTests
//  Created on 4/17/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import XCTest
@testable import NimbusKit
@testable import NimbusMobileFuseKit

@MainActor
final class MobileFuseAdControllerTests: XCTestCase {

    func test_mobile_fuse_ad_type() throws {
        // Banner
        var ad = getAd(markupType: .static)
        var controller = getController(ad: ad, isBlocking: false)
        
        XCTAssertEqual(controller.adRenderType, .banner)
        
        controller = getController(ad: ad, isBlocking: false)
        XCTAssertEqual(controller.adRenderType, .banner)
        
        // blocking interstitial
        ad = getAd(markupType: .static)
        controller = getController(ad: ad, isBlocking: true)
        XCTAssertEqual(controller.adRenderType, .interstitial)
        
        // Rewarded Video
        ad = getAd(markupType: .video)
        controller = getController(ad: ad, isBlocking: true, isRewarded: true)
        XCTAssertEqual(controller.adRenderType, .rewarded)
        
        // Rewarded static
        ad = getAd(markupType: .static)
        controller = getController(ad: ad, isBlocking: false, isRewarded: true)
        XCTAssertEqual(controller.adRenderType, .rewarded)
        
        // Video banner
        ad = getAd(markupType: .video)
        controller = getController(ad: ad, isBlocking: false)
        XCTAssertEqual(controller.adRenderType, .banner)
        
        // Native
        ad = getAd(markupType: .native)
        controller = getController(ad: ad, isBlocking: false)
        XCTAssertEqual(controller.adRenderType, .native)
                
        ad = getAd(markupType: .native)
        controller = getController(ad: ad, isBlocking: false)
        XCTAssertEqual(controller.adRenderType, .native)
    }
    
    private func getController(ad: NimbusResponse, isBlocking: Bool, isRewarded: Bool = false) -> NimbusMobileFuseAdController {
        NimbusMobileFuseAdController(
            response: ad,
            isBlocking: isBlocking,
            isRewarded: isRewarded,
            container: UIView(),
            adPresentingViewController: nil
        )
    }
    
    private func getAd(markupType: NimbusResponse.Bid.MarkupType, width: Int? = nil, height: Int? = nil) -> NimbusResponse {
        NimbusResponse(id: "", bid: .init(mtype: markupType, adm: "", price: 0, ext: .init(), w: width, h: height))
    }

}

extension MobileFuseAdControllerTests: AdController.Delegate {
    func didReceiveNimbusEvent(controller: AdController, event: AdEvent) {
    }
    
    func didReceiveNimbusError(controller: AdController, error: NimbusError) {
        
    }
}
