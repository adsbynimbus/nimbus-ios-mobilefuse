//
//  NimbusAd_MobileFuseTests.swift
//  NimbusMobileFuseKitTests
//
//  Created on 9/14/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import XCTest
import NimbusKit
@testable import NimbusMobileFuseKit
import MobileFuseSDK

final class NimbusAd_MobileFuseTests: XCTestCase {
    
    @MainActor
    func test_mobile_fuse_banner_size_translation() throws {
        var ad = getAd(markupType: .static)
        XCTAssertEqual(ad.mobileFuseBannerAdSize, .MOBILEFUSE_BANNER_SIZE_DEFAULT)
        
        ad = getAd(markupType: .video, width: 300, height: 50)
        XCTAssertEqual(ad.mobileFuseBannerAdSize, .MOBILEFUSE_BANNER_SIZE_300x50)
        
        ad = getAd(markupType: .video, width: 320, height: 50)
        XCTAssertEqual(ad.mobileFuseBannerAdSize, .MOBILEFUSE_BANNER_SIZE_320x50)
        
        ad = getAd(markupType: .video, width: 300, height: 250)
        XCTAssertEqual(ad.mobileFuseBannerAdSize, .MOBILEFUSE_BANNER_SIZE_300x250)
        
        ad = getAd(markupType: .video, width: 728, height: 90)
        XCTAssertEqual(ad.mobileFuseBannerAdSize, .MOBILEFUSE_BANNER_SIZE_728x90)
        
        ad = getAd(markupType: .video, width: 325, height: 56)
        XCTAssertEqual(ad.mobileFuseBannerAdSize, .MOBILEFUSE_BANNER_SIZE_DEFAULT)
    }
    
    @MainActor
    private func getAd(markupType: NimbusResponse.Bid.MarkupType, width: Int? = nil, height: Int? = nil) -> NimbusResponse {
        NimbusResponse(id: "", bid: .init(mtype: markupType, adm: "", price: 0, ext: .init(), w: width, h: height))
    }

}
