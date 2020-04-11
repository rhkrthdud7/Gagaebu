//
//  ListViewController.swift
//  Gagaebu
//
//  Created by Soso on 21/03/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import ReactorKit
import RealmSwift
import RxSwift
import RxCocoa
import RxViewController
import SnapKit
import ReusableKit

class ListViewController: BaseViewController, View {
    struct Reusable {
        static let listItemCell = ReusableCell<ListItemCell>()
    }
    
    var tableView = UITableView().then {
        $0.rowHeight = 70
        $0.register(Reusable.listItemCell)
    }
    var addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: nil)

    init(reactor: ListViewReactor) {
        super.init()

        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "List"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        navigationItem.rightBarButtonItem = addButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }

    func bind(reactor: ListViewReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map({ $0.items })
            .asObservable()
            .bind(to: tableView.rx.items(Reusable.listItemCell)) { (row, item, cell) in
                cell.labelTitle.text = item.title
                cell.labelDate.text = item.date.dateFormattedText
                cell.labelCost.text = item.cost.currencyFormattedText
            }.disposed(by: disposeBag)

        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let reactor = ItemViewReactor(itemService: reactor.itemService, mode: .new)
                let vc = ItemViewController(reactor: reactor)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let item = reactor.currentState.items[indexPath.row]
                let reactor = ItemViewReactor(itemService: reactor.itemService, mode: .edit(item))
                let vc = ItemViewController(reactor: reactor)
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
    }

}
