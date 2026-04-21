//
//  NimbusError+MobileFuse.swift
//  NimbusMobileFuseKit
//
//  Created on 2/23/26.
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit

extension NimbusError.Domain {
    static let mobileFuse = Self(rawValue: "mobileFuse")
}

extension NimbusError {
    static func mobileFuse(reason: Reason = .failure, stage: Stage, detail: String? = nil) -> NimbusError {
        NimbusError(reason: reason, domain: .mobileFuse, stage: stage, detail: detail)
    }
}
