//
//  SceneDelegate.swift
//  Gagaebu
//
//  Created by Soso on 21/03/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import RealmSwift
import URLNavigator

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigator: NavigatorType?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: scene)
        let itemService = ItemService()
        let listViewReactor = ListViewReactor(itemService: itemService)
        let listVC = ListViewController(reactor: listViewReactor)
        let nav = UINavigationController(rootViewController: listVC)
        nav.navigationBar.prefersLargeTitles = true
        let tab = UITabBarController()
        tab.setViewControllers([nav], animated: false)
        tab.tabBar.items?[0].image = #imageLiteral(resourceName: "icon_list_tab")
        tab.tabBar.isTranslucent = false
        window.rootViewController = tab
        window.makeKeyAndVisible()

        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {

                }
            })
        Realm.Configuration.defaultConfiguration = config

        let navigator = Navigator()
        NavigationMap.initialize(navigator: navigator, itemService: itemService)

        self.window = window
        self.navigator = navigator
        
        if let url = connectionOptions.urlContexts.first?.url {
            if navigator.push(url) != nil {
                return
            }
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if navigator?.push(url) != nil {
                return
            }
        }
    }
}

