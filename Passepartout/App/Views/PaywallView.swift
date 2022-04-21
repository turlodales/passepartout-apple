//
//  PaywallView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/12/22.
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

struct PaywallView: View {
    @ObservedObject private var productManager: ProductManager
    
    @Binding private var isPresented: Bool
    
    private let feature: LocalProduct?

    init<MT>(modalType: Binding<MT?>, feature: LocalProduct? = nil) {
        let isPresented = Binding<Bool> {
            modalType.wrappedValue != nil
        } set: {
            if !$0 {
                modalType.wrappedValue = nil
            }
        }
        self.init(isPresented: isPresented, feature: feature)
    }

    init(isPresented: Binding<Bool>, feature: LocalProduct? = nil) {
        productManager = .shared
        _isPresented = isPresented
        self.feature = feature
    }

    var body: some View {
        Group {
            if productManager.cfg.appType == .beta {
                BetaView()
            } else {
                PurchaseView(
                    isPresented: $isPresented,
                    feature: feature
                )
            }
        }.toolbar {
            themeCloseItem(isPresented: $isPresented)
        }.themeSecondaryView()
    }
}
