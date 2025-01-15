//
//  DNSView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

import Combine
import CommonUtils
import PassepartoutKit
import SwiftUI

struct DNSView: View, ModuleDraftEditing {

    @EnvironmentObject
    private var theme: Theme

    let module: DNSModule.Builder

    @ObservedObject
    var editor: ProfileEditor

    init(module: DNSModule.Builder, parameters: ModuleViewParameters) {
        self.module = module
        editor = parameters.editor
    }

    var body: some View {
        debugChanges()
        return Group {
            protocolSection
            Group {
                domainSection
                serversSection
                searchDomainsSection
            }
            .labelsHidden()
        }
        .themeManualInput()
        .moduleView(editor: editor, draft: draft.wrappedValue)
    }
}

private extension DNSView {
    static let allProtocols: [DNSProtocol] = [
        .cleartext,
        .https,
        .tls
    ]

    var protocolSection: some View {
        Section {
            Picker(Strings.Global.Nouns.protocol, selection: draft.protocolType) {
                ForEach(Self.allProtocols, id: \.self) {
                    Text($0.localizedDescription)
                }
            }
            switch draft.wrappedValue.protocolType {
            case .cleartext:
                EmptyView()

            case .https:
                ThemeTextField(Strings.Unlocalized.url, text: draft.dohURL, placeholder: Strings.Unlocalized.Placeholders.dohURL)
                    .labelsHidden()

            case .tls:
                ThemeTextField(Strings.Global.Nouns.hostname, text: draft.dotHostname, placeholder: Strings.Unlocalized.Placeholders.dotHostname)
                    .labelsHidden()

            @unknown default:
                EmptyView()
            }
        }
    }

    var domainSection: some View {
        Group {
            ThemeTextField(Strings.Global.Nouns.domain, text: draft.domainName ?? "", placeholder: Strings.Unlocalized.Placeholders.hostname)
        }
        .themeSection(header: Strings.Global.Nouns.domain)
    }

    var serversSection: some View {
        theme.listSection(
            Strings.Entities.Dns.servers,
            addTitle: Strings.Modules.Dns.Servers.add,
            originalItems: draft.servers,
            itemLabel: {
                if $0 {
                    Text($1.wrappedValue)
                } else {
                    ThemeTextField("", text: $1, placeholder: Strings.Unlocalized.Placeholders.ipV4DNS)
                }
            }
        )
    }

    var searchDomainsSection: some View {
        theme.listSection(
            Strings.Entities.Dns.searchDomains,
            addTitle: Strings.Modules.Dns.SearchDomains.add,
            originalItems: draft.searchDomains ?? [],
            itemLabel: {
                if $0 {
                    Text($1.wrappedValue)
                } else {
                    ThemeTextField("", text: $1, placeholder: Strings.Unlocalized.Placeholders.hostname)
                }
            }
        )
    }
}

// MARK: - Previews

#Preview {
    var module = DNSModule.Builder()
    module.protocolType = .https
    module.servers = ["1.1.1.1", "2.2.2.2", "3.3.3.3"]
    module.dohURL = "https://doh.com/query"
    module.dotHostname = "tls.com"
    module.domainName = "domain.com"
    module.searchDomains = ["one.com", "two.net", "three.com"]
    return module.preview()
}