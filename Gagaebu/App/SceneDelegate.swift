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
        let settingReactor = SettingViewReactor()
        let setingVC = SettingViewController(reactor: settingReactor)
        let tabC = UITabBarController()
        tabC.setViewControllers([
            listVC.navigationController(),
            setingVC.navigationController()
            ], animated: false)
        tabC.tabBar.isTranslucent = false
        tabC.tabBar.items?[0].image = #imageLiteral(resourceName: "icon_list_tab")
        tabC.tabBar.items?[1].image = #imageLiteral(resourceName: "icon_settings_tab")

        window.rootViewController = tabC
        window.makeKeyAndVisible()

        let config = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {

                }
            })
        Realm.Configuration.defaultConfiguration = config

        let navigator = Navigator()
        NavigationMap.initialize(navigator: navigator, rootVC: tabC, itemService: itemService)

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
