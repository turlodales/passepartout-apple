//
//  SettingsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/19/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import SwiftUI
import PassepartoutLibrary

struct SettingsView: View {
    @ObservedObject private var profileManager: ProfileManager

    @ObservedObject private var productManager: ProductManager
    
    @Environment(\.presentationMode) private var presentationMode
    
    @AppStorage(AppPreference.confirmsQuit.key) private var confirmsQuit = true
    
//    private var isTestBuild: Bool {
//        Constants.App.isBeta || Constants.InApp.appType == .beta
//    }
//    
//    private let appName = Unlocalized.appName

    private let versionString = Constants.Global.appVersionString

    init() {
        profileManager = .shared
        productManager = .shared
    }
    
    var body: some View {
        List {
            #if targetEnvironment(macCatalyst)
            preferencesSection
            #endif
            aboutSection
            diagnosticsSection
        }.toolbar {
            themeCloseItem(presentationMode: presentationMode)
        }.themeSecondaryView()
        .navigationTitle(L10n.Settings.title)
    }
    
    private var preferencesSection: some View {
        Section {
            Toggle(L10n.Preferences.Items.ConfirmQuit.caption, isOn: $confirmsQuit)
        }
    }
    
    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Text(L10n.About.title)
            }
            NavigationLink {
                DonateView()
            } label: {
                Text(L10n.Settings.Items.Donate.caption)
            }.disabled(!productManager.canMakePayments())
        } footer: {
            HStack {
                Spacer()
                Text(versionString)
                Spacer()
            }
        }
    }
    
    private var diagnosticsSection: some View {
        profileManager.activeProfile.map { profile in
            Section {
                NavigationLink {
                    DiagnosticsView(
                        vpnProtocol: profile.currentVPNProtocol,
                        providerName: profile.header.providerName
                    )
                } label: {
                    Text(L10n.Diagnostics.title)
                }
            }
        }
    }
}
