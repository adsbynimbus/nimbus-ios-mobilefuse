//
//  MobileFuseExtension.swift
//  Nimbus
//  Created on 3/28/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit

/// Nimbus extension for MobileFuse.
///
/// Enables MobileFuse rendering when included in `Nimbus.initialize(...)`.
/// Supports dynamic enable/disable at runtime.
///
/// ### Notes:
///   - Instantiate within the `Nimbus.initialize` block; the extension is installed and enabled automatically.
///   - Disable rendering with `MobileFuse.disable()`.
///   - Re-enable rendering with `MobileFuse.enable()`.
public struct MobileFuseExtension: NimbusRequestExtension, NimbusRenderExtension {
    @_documentation(visibility: internal)
    public var enabled = true
    
    @_documentation(visibility: internal)
    public var network: String { "mobilefusesdk" }
    
    @_documentation(visibility: internal)
    public var controllerType: AdController.Type { NimbusMobileFuseAdController.self }
    
    @_documentation(visibility: internal)
    public let interceptor: any NimbusRequest.Interceptor
    
    /// Creates a MobileFuse extension.
    ///
    /// Nimbus automatically initializes MobileFuseSDK if needed.
    ///
    /// ##### Usage
    /// ```swift
    /// Nimbus.initialize(publisher: "<publisher>", apiKey: "<apiKey>") {
    ///     MobileFuseExtension() // Enables MobileFuse rendering
    /// }
    /// ```
    public init() {
        self.interceptor = NimbusMobileFuseRequestInterceptor()
        
        Task { @MainActor in
            MobileFuseInitializer.shared.initIfNeeded()
        }
    }
    
    @_documentation(visibility: internal)
    public func coppaDidChange(coppa: Bool) {
        MobileFuseRequestBridge.set(coppa: coppa)
    }
}
