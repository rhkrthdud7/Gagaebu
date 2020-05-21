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

enum ItemPredicate {
    case transaction(Transaction)
    case period(Date, Date)
}

protocol ItemServiceType {
    func fetchItems(_ predicate: ItemPredicate?) -> Observable<[Item]>
    func create(_ title: String, _ cost: Int, _ date: Date, _ transaction: Transaction) -> Observable<Void>
    func update(_ id: String, _ title: String, _ cost: Int, _ date: Date, _ transaction: Transaction) -> Observable<Void>
    func delete(_ id: String) -> Observable<Void>
    func get(_ id: String) -> Item?
}

class ItemService: ItemServiceType {
    func fetchItems(_ predicate: ItemPredicate?) -> Observable<[Item]> {
        let realm = try! Realm()
        let items = realm.objects(Item.self)
            .sorted(byKeyPath: "date", ascending: false)
            .filter(predicate: predicate)
        return Observable.just(items.toArray(ofType: Item.self))
    }

    func create(_ title: String, _ cost: Int, _ date: Date, _ transaction: Transaction) -> Observable<Void> {
        let item = Item(title: title, cost: cost, date: date, transaction: transaction)
        let realm = try! Realm()
        try! realm.write {
            realm.create(Item.self, value: item)
        }
        return Observable.just(Void())
    }

    func update(_ id: String, _ title: String, _ cost: Int, _ date: Date, _ transaction: Transaction) -> Observable<Void> {
        let realm = try! Realm()
        if let item = realm.objects(Item.self)
            .filter("id == %@", id)
            .first {
            try! realm.write {
                item.title = title
                item.cost = cost
                item.date = date
                item.transaction = transaction
            }
        }
        return Observable.just(Void())
    }

    func delete(_ id: String) -> Observable<Void> {
        let realm = try! Realm()
        if let item = realm.objects(Item.self)
            .filter("id == %@", id)
            .first {
            try! realm.write {
                realm.delete(item)
            }
        }
        return Observable.just(Void())
    }

    func get(_ id: String) -> Item? {
        let realm = try! Realm()
        let item = realm.objects(Item.self).filter("id == %@", id).first
        return item
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

    func filter(predicate: ItemPredicate?) -> Results {
        guard let predicate = predicate else {
            return self
        }
        switch predicate {
        case .transaction(let transaction):
            return self.filter("transactionValue == %d", transaction.rawValue)
        case .period(let start, let end):
            return self.filter("date > %@ && date < %@", start, end)
        }
    }
}

class Item: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var cost: Int = 0
    @objc dynamic var date: Date = Date()
    @objc private dynamic var transactionValue: Int = 0
    var transaction: Transaction {
        get {
            return Transaction(rawValue: transactionValue)!
        }
        set {
            transactionValue = newValue.rawValue
        }
    }

    override class func indexedProperties() -> [String] {
        return ["id"]
    }

    convenience required init(title: String, cost: Int, date: Date, transaction: Transaction) {
        self.init()

        self.title = title
        self.cost = cost
        self.date = date
        self.transaction = transaction
    }

}
