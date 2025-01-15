//
//  AppProduct+Features.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

extension AppProduct {
    public enum Features {
        static let all: [AppProduct] = [
            .Features.allProviders,
            .Features.appleTV,
            .Features.networkSettings,
            .Features.trustedNetworks
        ]
    }

    public enum Full {
        static let all: [AppProduct] = [
            .Full.OneTime.allFeatures,
            .Full.Recurring.monthly,
            .Full.Recurring.yearly,
            //
            .Full.OneTime.iOS_macOS,
            .Full.OneTime.iOS,
            .Full.OneTime.macOS
        ]
    }

    static let featurePrefix = "features."

    private init(featureId: String) {
        self.init(rawValue: "\(Self.featurePrefix)\(featureId)")!
    }

    var isFeature: Bool {
        rawValue.hasPrefix(Self.featurePrefix)
    }
}

// MARK: - Current

extension AppProduct.Features {
    public static let appleTV = AppProduct(featureId: "appletv")
}

extension AppProduct.Full {
    public enum OneTime {
        public static let allFeatures = AppProduct(featureId: "full.lifetime")
    }

    public enum Recurring {
        public static let monthly = AppProduct(featureId: "full.monthly")

        public static let yearly = AppProduct(featureId: "full.yearly")
    }
}

extension AppProduct {
    public var isFullVersion: Bool {
        switch self {
        case .Full.Recurring.yearly,
                .Full.Recurring.monthly,
                .Full.OneTime.allFeatures,
                .Full.OneTime.iOS_macOS:
            return true
        default:
            return false
        }
    }

    public var isRecurring: Bool {
        switch self {
        case .Full.Recurring.monthly, .Full.Recurring.yearly:
            return true
        default:
            return false
        }
    }
}

// MARK: - Discontinued

extension AppProduct.Features {
    public static let allProviders = AppProduct(featureId: "all_providers")

    public static let networkSettings = AppProduct(featureId: "network_settings")

    public static let trustedNetworks = AppProduct(featureId: "trusted_networks")
}

extension AppProduct.Full.OneTime {

    @available(*, deprecated)
    public static let iOS_macOS = AppProduct(featureId: "full_multi_version")

    @available(*, deprecated)
    public static let iOS = AppProduct(featureId: "full_version")

    @available(*, deprecated)
    public static let macOS = AppProduct(featureId: "full_mac_version")
}