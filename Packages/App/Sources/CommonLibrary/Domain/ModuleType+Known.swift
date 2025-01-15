//
//  ModuleType+Known.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/2/24.
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
import PassepartoutKit

extension ModuleType: CaseIterable {
    public static let allCases: [ModuleType] = [
        .openVPN,
        .wireGuard,
        .dns,
        .httpProxy,
        .ip,
        .onDemand
    ]

    public static let openVPN = ModuleType(OpenVPNModule.self)

    public static let wireGuard = ModuleType(WireGuardModule.self)

    public static let dns = ModuleType(DNSModule.self)

    public static let httpProxy = ModuleType(HTTPProxyModule.self)

    public static let ip = ModuleType(IPModule.self)

    public static let onDemand = ModuleType(OnDemandModule.self)
}