//
//  AccessibilityInfo.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/27/24.
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

public struct AccessibilityInfo: Equatable, Sendable {
    public enum ElementType: Sendable {
        case button

        case link

        case menu

        case menuItem

        case text
    }

    public let id: String

    public let elementType: ElementType

    public init(_ id: String, _ elementType: ElementType) {
        self.id = id
        self.elementType = elementType
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}