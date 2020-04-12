//
//  NavigationMap.swift
//  Gagaebu
//
//  Created by Soso on 12/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import URLNavigator

struct NavigationMap {
    static func initialize(navigator: NavigatorType, itemService: ItemServiceType) {
        navigator.register("gagaebu://item/new") { (url, values, context) in
            let reactor = ItemViewReactor(itemService: itemService, mode: .new(.outcome))
            return ItemViewController(reactor: reactor)
        }
        navigator.register("gagaebu://item/edit/<id>") { (url, values, context) in
            guard let id = values["id"] as? String else { return nil }
            if let item = itemService.get(id) {
                let reactor = ItemViewReactor(itemService: itemService, mode: .edit(item))
                return ItemViewController(reactor: reactor)
            }
            return nil
        }
    }

}
