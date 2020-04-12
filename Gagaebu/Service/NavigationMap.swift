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
    static func initialize(navigator: NavigatorType, rootVC: UIViewController, itemService: ItemServiceType) {
        guard let tabC = rootVC as? UITabBarController else { return }
        guard let listNavC = tabC.viewControllers?[0] as? UINavigationController else { return }
        navigator.register("gagaebu://item/new") { (url, values, context) in
            tabC.selectedIndex = 0
            listNavC.popToRootViewController(animated: false)
            let reactor = ItemViewReactor(itemService: itemService, mode: .new(.outcome))
            return ItemViewController(reactor: reactor)
        }
        navigator.register("gagaebu://item/edit/<id>") { (url, values, context) in
            guard let id = values["id"] as? String else { return nil }
            if let item = itemService.get(id) {
                tabC.selectedIndex = 0
                listNavC.popToRootViewController(animated: false)
                let reactor = ItemViewReactor(itemService: itemService, mode: .edit(item))
                return ItemViewController(reactor: reactor)
            }
            return nil
        }
    }

}
