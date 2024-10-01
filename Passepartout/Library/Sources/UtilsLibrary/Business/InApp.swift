//
//  InApp.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/9/19.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

public enum InAppPurchaseResult: Sendable {
    case done

    case notFound

    case cancelled
}

public enum InAppError: Error {
    case unknown
}

public struct InAppProduct: Sendable {
    public let productIdentifier: String

    public let localizedTitle: String

    public let localizedPrice: String

    public let native: Sendable?

    public init(productIdentifier: String, localizedTitle: String, localizedPrice: String, native: Sendable?) {
        self.productIdentifier = productIdentifier
        self.localizedTitle = localizedTitle
        self.localizedPrice = localizedPrice
        self.native = native
    }
}

public protocol InAppIdentifierProviding {
    var inAppIdentifier: String { get }
}

public protocol InAppHelper {
    associatedtype ProductIdentifier: Hashable & InAppIdentifierProviding

    var canMakePurchases: Bool { get }

    var products: [ProductIdentifier: InAppProduct] { get async }

    func fetchProducts() async throws

    func purchase(productWithIdentifier productIdentifier: ProductIdentifier) async throws -> InAppPurchaseResult

    func restorePurchases() async throws
}

public struct InAppReceipt: Sendable {
    public struct PurchaseReceipt: Sendable {
        public let productIdentifier: String?

        public let cancellationDate: Date?

        public let originalPurchaseDate: Date?

        public init(productIdentifier: String?, cancellationDate: Date?, originalPurchaseDate: Date?) {
            self.productIdentifier = productIdentifier
            self.cancellationDate = cancellationDate
            self.originalPurchaseDate = originalPurchaseDate
        }
    }

    public let originalBuildNumber: Int?

    public let purchaseReceipts: [PurchaseReceipt]?

    public init(originalBuildNumber: Int?, purchaseReceipts: [PurchaseReceipt]?) {
        self.originalBuildNumber = originalBuildNumber
        self.purchaseReceipts = purchaseReceipts
    }
}

public protocol InAppReceiptReader {
    associatedtype UserLevel

    func receipt(for userLevel: UserLevel) async -> InAppReceipt?
}