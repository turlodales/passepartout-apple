//
//  ProfileEditor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

import Combine
import CommonLibrary
import Foundation
import PassepartoutKit

@MainActor
public final class ProfileEditor: ObservableObject {

    @Published
    private var editableProfile: EditableProfile

    @Published
    public var isShared: Bool

    @Published
    public var preferences: [UUID: ModulePreferences]

    private(set) var removedModules: [UUID: any ModuleBuilder]

    public convenience init() {
        self.init(modules: [])
    }

    // for testing/previews
    public init(profile: Profile) {
        editableProfile = profile.editable()
        isShared = false
        preferences = [:]
        removedModules = [:]
    }

    // for testing/previews
    public init(modules: [any ModuleBuilder]) {
        editableProfile = EditableProfile(
            modules: modules,
            activeModulesIds: Set(modules.map(\.id))
        )
        isShared = false
        preferences = [:]
        removedModules = [:]
    }
}

// MARK: - Types

extension ProfileEditor {
    public var moduleTypes: [ModuleType] {
        editableProfile.modules
            .map(\.moduleType)
    }

    public var availableModuleTypes: [ModuleType] {
        ModuleType
            .allCases
            .filter {
                // TODO: #657, hide manual OpenVPN/WireGuard until editable
//                $0 != .openVPN && $0 != .wireGuard
                $0 != .wireGuard
            }
            .filter {
                !moduleTypes.contains($0)
            }
            .sorted {
                $0.localizedDescription.lowercased() < $1.localizedDescription.lowercased()
            }
    }
}

// MARK: - Editing

extension ProfileEditor {
    public var profile: EditableProfile {
        get {
            editableProfile
        }
        set {
            editableProfile = newValue
        }
    }

    public var isAvailableForTV: Bool {
        get {
            editableProfile.attributes.isAvailableForTV == true
        }
        set {
            editableProfile.attributes.isAvailableForTV = newValue
        }
    }
}

extension ProfileEditor {
    public var modules: [any ModuleBuilder] {
        editableProfile.modules
    }

    public var activeModules: [any ModuleBuilder] {
        editableProfile.modules.filter {
            isActiveModule(withId: $0.id)
        }
    }

    public func module(withId moduleId: UUID) -> (any ModuleBuilder)? {
        editableProfile.modules.first {
            $0.id == moduleId
        } ?? removedModules[moduleId]
    }

    public func isActiveModule(withId moduleId: UUID) -> Bool {
        editableProfile.isActiveModule(withId: moduleId)
    }

    public func toggleModule(withId moduleId: UUID) {
        guard let existingModule = module(withId: moduleId) else {
            return
        }
        if isActiveModule(withId: moduleId) {
            editableProfile.activeModulesIds.remove(moduleId)
        } else {
            activateModule(existingModule)
        }
    }

    public func moveModules(from offsets: IndexSet, to newOffset: Int) {
        editableProfile.modules.move(fromOffsets: offsets, toOffset: newOffset)
    }

    public func removeModules(at offsets: IndexSet) {
        offsets.forEach {
            let module = editableProfile.modules[$0]
            removedModules[module.id] = module
            editableProfile.modules.remove(at: $0)
        }
    }

    public func removeModule(withId moduleId: UUID) {
        guard let index = editableProfile.modules.firstIndex(where: { $0.id == moduleId }) else {
            return
        }
        let module = editableProfile.modules[index]
        removedModules[module.id] = module
        editableProfile.modules.remove(at: index)
    }

    public func saveModule(_ module: any ModuleBuilder, activating: Bool) {
        if let index = editableProfile.modules.firstIndex(where: { $0.id == module.id }) {
            editableProfile.modules[index] = module
        } else {
            editableProfile.modules.append(module)
        }
        if activating {
            activateModule(module)
        }
    }
}

private extension ProfileEditor {
    func activateModule(_ module: any ModuleBuilder) {
        editableProfile.activeModulesIds.insert(module.id)
    }
}

// MARK: - Building

extension ProfileEditor {
    public func build() throws -> Profile {
        let builder = try editableProfile.builder()
        let profile = try builder.tryBuild()

        // update local view
        editableProfile.modules = profile.modulesBuilders()
        removedModules.removeAll()

        return profile
    }
}

// MARK: - Load/Save

extension ProfileEditor {
    public func load(
        _ profile: EditableProfile,
        isShared: Bool,
        preferencesManager: PreferencesManager
    ) {
        editableProfile = profile
        self.isShared = isShared
        do {
            preferences = try preferencesManager.preferences(forProfile: profile)
        } catch {
            preferences = [:]
            pp_log(.App.profiles, .error, "Unable to load preferences for profile \(profile.id): \(error)")
        }
        removedModules = [:]
    }

    @discardableResult
    public func save(
        to profileManager: ProfileManager,
        preferencesManager: PreferencesManager
    ) async throws -> Profile {
        do {
            let newProfile = try build()
            try await profileManager.save(newProfile, isLocal: true, remotelyShared: isShared)
            do {
                try preferencesManager.savePreferences(preferences)
            } catch {
                pp_log(.App.profiles, .error, "Unable to save preferences for profile \(profile.id): \(error)")
            }
            return newProfile
        } catch {
            pp_log(.App.profiles, .fault, "Unable to save edited profile: \(error)")
            throw error
        }
    }

    public func discard() {
    }
}

// MARK: - Testing

extension ProfileEditor {
    var activeModulesIds: Set<UUID> {
        editableProfile.activeModulesIds
    }
}