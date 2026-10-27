//
//  MobileFuseAdControllerTests.swift
//  NimbusMobileFuseKitTests
//  Created on 10/21/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Testing
@testable import NimbusMobileFuseKit
@testable import NimbusKit
import UIKit
import MobileFuseSDK

private let placementId = "test-placement-id"
private let bidToken = "test-bid-token"

/// MFAd exposes no delegate getter: the controller hands itself over in `registerAdCallbackReceiver:`.
/// `MFAdStubs` captures that receiver (proving the wiring) and stubs load/show/destroy so no real
/// MobileFuse request is made. Callbacks are then fired through the captured receiver.
@Suite("MobileFuse AdController tests")
@MainActor
struct MobileFuseAdControllerTests {

    // MARK: - Banner

    @Test func bannerAdEventsGetFired() throws {
        let stubs = MFAdStubs(MFBannerAd.self)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(.banner)
        adController.load()

        let ad = try #require(stubs.ad)
        #expect(ad is MFBannerAd)
        #expect(ad.superview === adController.adView)
        #expect(stubs.loadedToken == bidToken)

        let mf = try #require(stubs.receiver, "callback receiver not registered")
        #expect(mf === adController)

        mf.onAdLoaded?()
        #expect(delegate.events == [.loaded])
        #expect(stubs.showCount == 0)

        adController.start()
        #expect(stubs.showCount == 1)

        mf.onAdRendered?()
        #expect(delegate.events == [.loaded, .impression])

        mf.onAdClicked?()
        #expect(delegate.events == [.loaded, .impression, .clicked])
        #expect(delegate.lastError == nil)

        mf.onAdClosed?()
        #expect(delegate.lastError == nil)
        #expect(delegate.events.last == .destroyed)
        #expect(stubs.destroyCount == 1)
    }

    @Test func bannerMuteFollowsVolume() throws {
        let stubs = MFAdStubs(MFBannerAd.self)
        defer { stubs.restore() }

        let (adController, _) = makeAdController(.banner)
        adController.load()
        #expect(!stubs.mutedValues.isEmpty)

        adController.volume = 100
        #expect(stubs.mutedValues.last == false)

        adController.volume = 0
        #expect(stubs.mutedValues.last == true)
    }

    // MARK: - Interstitial

    @Test func interstitialAdEventsGetFired() throws {
        let stubs = MFAdStubs(MFInterstitialAd.self)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(.interstitial)
        adController.load()

        let ad = try #require(stubs.ad)
        #expect(ad is MFInterstitialAd)
        #expect(!(ad is MFRewardedAd))
        #expect(ad.superview === presenter.view)
        #expect(stubs.loadedToken == bidToken)

        let mf = try #require(stubs.receiver, "callback receiver not registered")
        #expect(mf === adController)

        mf.onAdLoaded?()
        #expect(delegate.events == [.loaded])
        #expect(stubs.showCount == 0)

        adController.start()
        #expect(stubs.showCount == 1)

        mf.onAdRendered?()
        #expect(delegate.events == [.loaded, .impression])

        mf.onAdClicked?()
        #expect(delegate.events == [.loaded, .impression, .clicked])
        #expect(delegate.lastError == nil)

        mf.onAdClosed?()
        #expect(delegate.lastError == nil)
        #expect(!delegate.events.contains(.rewardEarned))
        #expect(delegate.events.last == .destroyed)
        #expect(stubs.destroyCount == 1)
    }

    // MARK: - Rewarded

    @Test func rewardedAdEventsGetFired() throws {
        let stubs = MFAdStubs(MFRewardedAd.self)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(.rewarded)
        adController.load()

        let ad = try #require(stubs.ad)
        #expect(ad is MFRewardedAd)
        #expect(ad.superview === presenter.view)
        #expect(stubs.loadedToken == bidToken)

        let mf = try #require(stubs.receiver, "callback receiver not registered")
        #expect(mf === adController)

        mf.onAdLoaded?()
        #expect(delegate.events == [.loaded])

        adController.start()
        #expect(stubs.showCount == 1)

        mf.onAdRendered?()
        #expect(delegate.events == [.loaded, .impression])

        mf.onAdClicked?()
        #expect(delegate.events == [.loaded, .impression, .clicked])

        mf.onUserEarnedReward?()
        #expect(delegate.events == [.loaded, .impression, .clicked, .rewardEarned])
        #expect(delegate.lastError == nil)

        mf.onAdClosed?()
        #expect(delegate.lastError == nil)
        #expect(delegate.events.last == .destroyed)
        #expect(stubs.destroyCount == 1)
    }

    // MARK: - Errors (shared by every format: one callback receiver for all)

    @Test(arguments: [Format.banner, .interstitial, .rewarded])
    func adGetsDestroyedOnErrorMessage(_ format: Format) throws {
        let stubs = MFAdStubs(format.adClass)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(format)
        adController.load()
        let mf = try #require(stubs.receiver, "callback receiver not registered")

        mf.onAdError?("MobileFuse test error")

        expectMobileFuseError(delegate, detail: "MobileFuse test error")
        #expect(delegate.events.last == .destroyed)
        #expect(stubs.destroyCount == 1)
    }

    @Test(arguments: [Format.banner, .interstitial, .rewarded])
    func adGetsDestroyedOnAdError(_ format: Format) throws {
        let stubs = MFAdStubs(format.adClass)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(format)
        adController.load()
        let ad = try #require(stubs.ad)
        let mf = try #require(stubs.receiver, "callback receiver not registered")

        let error = MFAdError(domain: "com.mobilefuse.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "MobileFuse test error"])
        mf.onAdError?(ad, withError: error)

        #expect(delegate.lastError != nil)
        #expect(delegate.lastError!.domain == NimbusError.Domain(rawValue: "mobileFuse"))
        #expect(delegate.lastError!.detail != nil)
        #expect(delegate.events.last == .destroyed)
    }

    @Test(arguments: [Format.banner, .interstitial, .rewarded])
    func adGetsDestroyedWhenNotFilled(_ format: Format) throws {
        let stubs = MFAdStubs(format.adClass)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(format)
        adController.load()
        let mf = try #require(stubs.receiver, "callback receiver not registered")

        mf.onAdNotFilled?()

        expectMobileFuseError(delegate, detail: "No ad available")
        #expect(delegate.lastError?.reason != .noFill)
        #expect(!delegate.events.contains(.loaded))
        #expect(delegate.events.last == .destroyed)
    }

    @Test(arguments: [Format.banner, .interstitial, .rewarded])
    func adGetsDestroyedWhenExpired(_ format: Format) throws {
        let stubs = MFAdStubs(format.adClass)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(format)
        adController.load()
        let mf = try #require(stubs.receiver, "callback receiver not registered")

        mf.onAdLoaded?()
        mf.onAdExpired?()

        expectMobileFuseError(delegate, detail: "Ad expired")
        #expect(delegate.events.last == .destroyed)
    }

    // MARK: - Load validation

    @Test func nativeIsNotSupported() {
        let stubs = MFAdStubs(MFAd.self)
        defer { stubs.restore() }

        let (adController, delegate) = makeAdController(.native)
        adController.load()

        #expect(stubs.ad == nil)
        #expect(delegate.lastError?.reason == .unsupported)
        #expect(delegate.events.last == .destroyed)
    }

    @Test func loadFailsWithoutPlacementId() {
        let stubs = MFAdStubs(MFBannerAd.self)
        defer { stubs.restore() }

        let adController = NimbusMobileFuseAdController(
            response: NimbusResponse(id: "", bid: .init(mtype: .static, adm: bidToken, price: 0, ext: .init())),
            isBlocking: false,
            isRewarded: false,
            container: container,
            adPresentingViewController: presenter
        )
        let delegate = MockDelegate()
        adController.delegate = delegate

        adController.load()

        #expect(stubs.ad == nil)
        #expect(delegate.lastError?.detail == "Placement Id not found.")
        #expect(delegate.events.last == .destroyed)
    }

    @Test func adRenderTypeIsMappedFromResponse() {
        #expect(controller(.static, isBlocking: false).adRenderType == .banner)
        #expect(controller(.static, isBlocking: true).adRenderType == .interstitial)
        #expect(controller(.video, isBlocking: true, isRewarded: true).adRenderType == .rewarded)
        #expect(controller(.static, isBlocking: false, isRewarded: true).adRenderType == .rewarded)
        #expect(controller(.video, isBlocking: false).adRenderType == .banner)
        #expect(controller(.native, isBlocking: false).adRenderType == .native)
    }

    // MARK: - Helpers

    /// Fresh per test: Swift Testing creates a new suite instance for every @Test.
    private let container = UIView()

    /// AdController holds adPresentingViewController weakly, so it must outlive the test body.
    private let presenter = UIViewController()

    enum Format: CustomTestStringConvertible {
        case banner, native, interstitial, rewarded

        var adClass: MFAd.Type {
            switch self {
            case .banner: MFBannerAd.self
            case .interstitial: MFInterstitialAd.self
            case .rewarded: MFRewardedAd.self
            case .native: MFAd.self
            }
        }

        var testDescription: String { "\(self)" }
    }

    private func makeAdController(_ format: Format) -> (NimbusMobileFuseAdController, MockDelegate) {
        let mtype: NimbusResponse.Bid.MarkupType = switch format {
        case .banner, .interstitial: .static
        case .native: .native
        case .rewarded: .video
        }

        let adController = NimbusMobileFuseAdController(
            response: NimbusResponse(id: "", bid: .init(
                mtype: mtype,
                adm: bidToken,
                price: 0,
                ext: .init(omp: .init(buyer: "mobilefuse", buyerPlacementId: placementId)),
                w: 320,
                h: 50
            )),
            isBlocking: format == .interstitial || format == .rewarded,
            isRewarded: format == .rewarded,
            container: container,
            adPresentingViewController: presenter
        )
        let delegate = MockDelegate()
        adController.delegate = delegate
        return (adController, delegate)
    }

    private func controller(
        _ markupType: NimbusResponse.Bid.MarkupType,
        isBlocking: Bool,
        isRewarded: Bool = false
    ) -> NimbusMobileFuseAdController {
        NimbusMobileFuseAdController(
            response: NimbusResponse(id: "", bid: .init(mtype: markupType, adm: "", price: 0, ext: .init())),
            isBlocking: isBlocking,
            isRewarded: isRewarded,
            container: container,
            adPresentingViewController: nil
        )
    }

    private func expectMobileFuseError(
        _ delegate: MockDelegate,
        detail: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        // Exactly one error: a second one would replace the first in `lastError` and hide it
        let details = delegate.errors.map { $0.detail ?? "nil" }
        #expect(delegate.errors.count == 1, "errors received: \(details)", sourceLocation: sourceLocation)

        guard let error = delegate.errors.first else {
            Issue.record("no error received", sourceLocation: sourceLocation)
            return
        }
        #expect(error.domain == NimbusError.Domain(rawValue: "mobileFuse"), sourceLocation: sourceLocation)
        #expect(error.detail == detail, "errors received: \(details)", sourceLocation: sourceLocation)
    }
}

// MARK: - Mocks

class MockDelegate: AdController.Delegate {
    var events: [AdEvent] = []
    /// Every error received, in order, so a test can tell one error from a later one replacing it.
    var errors: [NimbusError] = []
    var lastError: NimbusError? { errors.last }

    func didReceiveNimbusEvent(event: NimbusKit.AdEvent) {
        events.append(event)
    }

    func didReceiveNimbusError(error: NimbusKit.NimbusError) {
        errors.append(error)
    }
}

/// Stubs the MFAd methods the controller calls, for one ad class, until `restore()`.
final class MFAdStubs {
    weak var ad: MFAd?
    weak var receiver: (any IMFAdCallbackReceiver)?
    var loadedToken: String?
    var showCount = 0
    var destroyCount = 0
    var mutedValues: [Bool] = []

    private var stubs: [MethodStub] = []

    init(_ cls: MFAd.Type) {
        stubs = [
            MethodStub(cls, "registerAdCallbackReceiver:", with: { [weak self] (ad: AnyObject, receiver: AnyObject?) in
                self?.ad = ad as? MFAd
                self?.receiver = receiver as? IMFAdCallbackReceiver
            } as @convention(block) (AnyObject, AnyObject?) -> Void),
            MethodStub(cls, "loadAdWithBiddingResponseToken:", with: { [weak self] (_: AnyObject, token: NSString?) in
                self?.loadedToken = token as String?
            } as @convention(block) (AnyObject, NSString?) -> Void),
            MethodStub(cls, "showAd", with: { [weak self] (_: AnyObject) in
                self?.showCount += 1
            } as @convention(block) (AnyObject) -> Void),
            MethodStub(cls, "destroy", with: { [weak self] (_: AnyObject) in
                self?.destroyCount += 1
            } as @convention(block) (AnyObject) -> Void),
            MethodStub(cls, "setMuted:", with: { [weak self] (_: AnyObject, muted: Bool) in
                self?.mutedValues.append(muted)
            } as @convention(block) (AnyObject, Bool) -> Void),
        ]
    }

    func restore() {
        stubs.reversed().forEach { $0.restore() }
    }
}

/// Swaps an Objective-C method implementation until `restore()`. The swap applies to every instance
/// of the class (and of subclasses that inherit the method), so always restore with `defer`.
final class MethodStub {
    private let method: Method
    private let original: IMP

    init(_ cls: AnyClass, _ selector: String, with block: Any) {
        method = class_getInstanceMethod(cls, NSSelectorFromString(selector))!
        original = method_setImplementation(method, imp_implementationWithBlock(block))
    }

    func restore() {
        method_setImplementation(method, original)
    }
}
