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

enum Transaction: Int {
    case outcome = 0, income

    var title: String {
        switch self {
        case .outcome:
            return "지출"
        case .income:
            return "수입"
        }
    }
}

class ListViewController: BaseViewController, View {
    struct Reusable {
        static let listItemCell = ReusableCell<ListItemCell>()
    }

    let tableView = UITableView().then {
        $0.rowHeight = 70
        $0.register(Reusable.listItemCell)
    }
    let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: nil)
    let header = UIView().then {
        let width = UIScreen.main.bounds.width
        $0.frame = CGRect(x: 0, y: 0, width: width, height: 64)
    }
    let segmentedControl = UISegmentedControl().then {
        $0.insertSegment(withTitle: Transaction.income.title, at: 0, animated: false)
        $0.insertSegment(withTitle: Transaction.outcome.title, at: 0, animated: false)
        $0.selectedSegmentIndex = 0
    }

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

        tableView.tableHeaderView = header
        header.addSubview(segmentedControl)
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        segmentedControl.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16).priority(999)
        }
    }

    func bind(reactor: ListViewReactor) {
        rx.viewWillAppear
            .withLatestFrom(segmentedControl.rx.selectedSegmentIndex)
            .map(Transaction.init)
            .filterNil()
            .map(Reactor.Action.refresh)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        segmentedControl.rx.controlEvent(.valueChanged)
            .withLatestFrom(segmentedControl.rx.selectedSegmentIndex)
            .map(Transaction.init)
            .filterNil()
            .map(Reactor.Action.refresh)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .map { reactor.currentState.transaction }
            .subscribe(onNext: { [weak self] transaction in
                guard let self = self else { return }
                let reactor = ItemViewReactor(itemService: reactor.itemService, mode: .new(transaction))
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

        reactor.state
            .map({ $0.items })
            .asObservable()
            .bind(to: tableView.rx.items(Reusable.listItemCell)) { (row, item, cell) in
                cell.labelTitle.text = item.title
                cell.labelDate.text = item.date.dateFormattedText
                cell.labelCost.text = item.cost.currencyFormattedText
            }.disposed(by: disposeBag)

        reactor.state
            .map { $0.transaction.rawValue }
            .bind(to: segmentedControl.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
    }

}
