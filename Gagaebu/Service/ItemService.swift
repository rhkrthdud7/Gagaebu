//
//  ItemService.swift
//  Gagaebu
//
//  Created by Soso on 07/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol ItemServiceType {
    func fetchItems() -> Observable<[Item]>
    func create(title: String, cost: Int, date: Date) -> Observable<Void>
    func update(id: String, title: String, cost: Int, date: Date) -> Observable<Void>
}

class ItemService: ItemServiceType {
    func fetchItems() -> Observable<[Item]> {
        let realm = try! Realm()
        let items = realm.objects(Item.self)
            .sorted(byKeyPath: "date", ascending: false)
        return Observable.just(items.toArray(ofType: Item.self))
    }

    func create(title: String, cost: Int, date: Date) -> Observable<Void> {
        let item = Item(title: title, cost: cost, date: date)
        let realm = try! Realm()
        try! realm.write {
            realm.create(Item.self, value: item)
        }
        return Observable.just(Void())
    }

    func update(id: String, title: String, cost: Int, date: Date) -> Observable<Void> {
        let realm = try! Realm()
        if let item = realm.objects(Item.self)
            .filter("id == %@", id)
            .first {
            try! realm.write {
                item.title = title
                item.cost = cost
                item.date = date
            }
        }
        return Observable.just(Void())
    }

}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}

class Item: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var cost: Int = 0
    @objc dynamic var date: Date = Date()

    override class func indexedProperties() -> [String] {
        return ["id"]
    }

    convenience required init(title: String, cost: Int, date: Date) {
        self.init()

        self.title = title
        self.cost = cost
        self.date = date
    }

}
