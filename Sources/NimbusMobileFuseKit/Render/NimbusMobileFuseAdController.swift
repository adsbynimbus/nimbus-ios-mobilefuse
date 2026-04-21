//
//  NimbusMobileFuseAdController.swift
//  NimbusMobileFuseKit
//
//  Created on 9/8/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusKit
import MobileFuseSDK

final class NimbusMobileFuseAdController: AdController, @preconcurrency IMFAdCallbackReceiver {
    
    // MARK: - Properties
    
    // MARK: AdController properties
    
    override var volume: Int {
        didSet {
            bannerAd?.setMuted(isMuted)
        }
    }
    
    // MARK: Private
    
    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false
    
    private var isMuted: Bool { volume == 0 }
    
    // MARK: MobileFuse
    private var bannerAd: MFBannerAd?
    private var interstitialAd: MFInterstitialAd?
    private var rewardedAd: MFRewardedAd?
    
    override class func setup(
        response: NimbusResponse,
        container: UIView,
        adPresentingViewController: UIViewController?
    ) -> AdController {
        let controller = Self.init(
            response: response,
            isBlocking: false,
            isRewarded: false,
            container: container,
            adPresentingViewController: adPresentingViewController
        )
        
        return controller
    }
    
    override class func setupBlocking(
        response: NimbusResponse,
        isRewarded: Bool,
        adPresentingViewController: UIViewController?
    ) -> AdController {
        let controller = Self.init(
            response: response,
            isBlocking: true,
            isRewarded: isRewarded,
            container: nil,
            adPresentingViewController: adPresentingViewController
        )
        
        return controller
    }
    
    override func load() {
        guard let placementId = response.bid.ext?.omp?.buyerPlacementId else {
            sendNimbusError(.mobileFuse(stage: .render, detail: "Placement Id not found."))
            return
        }
        
        switch adRenderType {
        case .banner:
            bannerAd = MFBannerAd(placementId: placementId, with: response.mobileFuseBannerAdSize)
            bannerAd!.register(self)
            adView.addSubview(bannerAd!)
            
            bannerAd!.load(withBiddingResponseToken: response.bid.adm)
            bannerAd!.setMuted(isMuted)
        case .interstitial:
            interstitialAd = MFInterstitialAd(placementId: placementId)
            interstitialAd!.register(self)
            adPresentingViewController?.view.addSubview(interstitialAd!)
            interstitialAd!.load(withBiddingResponseToken: response.bid.adm)
        case .rewarded:
            rewardedAd = MFRewardedAd(placementId: placementId)
            rewardedAd!.register(self)
            adPresentingViewController?.view.addSubview(rewardedAd!)
            rewardedAd!.load(withBiddingResponseToken: response.bid.adm)
        default:
            sendNimbusError(.mobileFuse(reason: .unsupported, stage: .render, detail: "adRenderType: \(adRenderType.rawValue)"))
        }
    }
    
    private func presentAd() {
        guard started, adState == .ready else { return }
        
        adState = .resumed
        
        switch adRenderType {
        case .banner:
            self.bannerAd?.show()
        case .interstitial:
            self.interstitialAd?.show()
        case .rewarded:
            self.rewardedAd?.show()
        default:
            sendNimbusError(.mobileFuse(reason: .invalidState, stage: .render, detail: "Ad \(adRenderType) is invalid and could not be presented."))
        }
    }
    
    // MARK: - AdController overrides
    
    override func onStart() {
        if adState == .ready {
            presentAd()
        }
    }
    
    override func onDestroy() {
        bannerAd?.destroy()
        interstitialAd?.destroy()
        rewardedAd?.destroy()
    }
    
    // MARK: - IMFAdCallbackReceiver
    
    func onAdLoaded() {
        adState = .ready
        
        Nimbus.Log.ad.debug("MobileFuse Event: \(#function)")
        sendNimbusEvent(.loaded)
        
        presentAd()
    }
    
    func onAdError(_ message: String!) {
        sendNimbusError(.mobileFuse(stage: .render, detail: message))
    }
    
    func onAdRendered() {
        Nimbus.Log.ad.debug("MobileFuse Event: \(#function)")
        
        if adRenderType == .banner {
            hasRegisteredAdImpression = true
        }
        
        sendNimbusEvent(.impression)
    }
    
    func onUserEarnedReward() {
        Nimbus.Log.ad.debug("MobileFuse Event: \(#function)")
        sendNimbusEvent(.completed)
    }
    
    func onAdClosed() {
        Nimbus.Log.ad.debug("MobileFuse Event: \(#function)")
        destroy()
    }
    
    func onAdClicked() {
        Nimbus.Log.ad.debug("MobileFuse Event: \(#function)")
        sendNimbusEvent(.clicked)
    }
}

// Internal: Do NOT implement delegate conformance as separate extensions as the methods won't not be found in runtime when built as a static library
