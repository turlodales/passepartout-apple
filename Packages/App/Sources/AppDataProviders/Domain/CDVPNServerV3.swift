//
//  CDVPNServerV3.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/26/24.
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

import CoreData
import Foundation

@objc(CDVPNServerV3)
final class CDVPNServerV3: NSManagedObject {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDVPNServerV3> {
        NSFetchRequest<CDVPNServerV3>(entityName: "CDVPNServerV3")
    }

    @NSManaged var serverId: String?
    @NSManaged var hostname: String?
    @NSManaged var ipAddresses: Data?
    @NSManaged var providerId: String?
    @NSManaged var countryCode: String?
    @NSManaged var supportedConfigurationIds: String?
    @NSManaged var supportedPresetIds: String?
    @NSManaged var categoryName: String?
    @NSManaged var localizedCountry: String?
    @NSManaged var otherCountryCodes: String?
    @NSManaged var area: String?
}