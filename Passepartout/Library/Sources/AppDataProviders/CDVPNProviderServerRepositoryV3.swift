//
//  CDVPNProviderServerRepositoryV3.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/26/24.
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

import AppData
import CoreData
import Foundation
import PassepartoutKit
import UtilsLibrary

final class CDVPNProviderServerRepositoryV3: VPNProviderServerRepository {
    private let context: NSManagedObjectContext

    let providerId: ProviderID

    init(context: NSManagedObjectContext, providerId: ProviderID) {
        self.context = context
        self.providerId = providerId
    }

    func availableOptions<Configuration>(for configurationType: Configuration.Type) async throws -> VPNFilterOptions where Configuration: ProviderConfigurationIdentifiable {
        try await context.perform {
            let mapper = DomainMapper()

            let serversRequest = NSFetchRequest<NSDictionary>(entityName: "CDVPNServerV3")
            serversRequest.predicate = self.providerId.predicate
            serversRequest.resultType = .dictionaryResultType
            serversRequest.returnsDistinctResults = true
            serversRequest.propertiesToFetch = [
                "categoryName",
                "countryCode"
            ]
            let serversResults = try serversRequest.execute()
            let categoryNames = serversResults.compactMap {
                $0.object(forKey: "categoryName") as? String
            }
            let countryCodes = serversResults.compactMap {
                $0.object(forKey: "countryCode") as? String
            }

            let presetsRequest = CDVPNPresetV3.fetchRequest()
            presetsRequest.predicate = NSPredicate(
                format: "providerId == %@ AND configurationId == %@", self.providerId.rawValue,
                Configuration.providerConfigurationIdentifier
            )
            let presetsResults = try presetsRequest.execute()

            return VPNFilterOptions(
                categoryNames: Set(categoryNames),
                countryCodes: Set(countryCodes),
                presets: Set(try presetsResults.compactMap {
                    try mapper.preset(from: $0)
                })
            )
        }
    }

    func filteredServers(with parameters: VPNServerParameters?) async throws -> [VPNServer] {
        try await context.perform {
            let request = CDVPNServerV3.fetchRequest()
            request.sortDescriptors = parameters?.sorting.map(\.sortDescriptor)
            request.predicate = parameters?.filters.predicate(for: self.providerId)
            let results = try request.execute()
            let mapper = DomainMapper()
            return try results.compactMap(mapper.server(from:))
        }
    }
}
