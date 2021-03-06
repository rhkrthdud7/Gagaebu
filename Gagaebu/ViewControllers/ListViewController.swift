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
        $0.rowHeight = 90
        $0.separatorStyle = .none
        $0.register(Reusable.listItemCell)
    }
    let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: nil)
    let header = UIView().then {
        $0.backgroundColor = .clear
    }
    let buttonPrevious = UIButton(type: .system).then {
        $0.setImage(#imageLiteral(resourceName: "icon_back"), for: .normal)
        $0.tintColor = .label
    }
    let buttonNext = UIButton(type: .system).then {
        $0.setImage(#imageLiteral(resourceName: "icon_next"), for: .normal)
        $0.tintColor = .label
    }
    let labelCurrent = UILabel().then {
        $0.textAlignment = .center
    }
    let segmentedControl = UISegmentedControl().then {
        $0.insertSegment(withTitle: Transaction.income.title, at: 0, animated: false)
        $0.insertSegment(withTitle: Transaction.outcome.title, at: 0, animated: false)
        $0.selectedSegmentIndex = 0
    }
    let labelOutcome = UILabel().then {
        $0.textAlignment = .left
    }
    let labelIncome = UILabel().then {
        $0.textAlignment = .left
    }
    let labelTotal = UILabel().then {
        $0.textAlignment = .left
    }
    let labelEmpty = UILabel().then {
        $0.text = "새로운 아이템을 등록해주세요 :)"
        $0.textAlignment = .center
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

        navigationItem.title = "List"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        navigationItem.rightBarButtonItem = addButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)

        tableView.tableHeaderView = header
        tableView.addSubview(labelEmpty)
        header.addSubview(buttonPrevious)
        header.addSubview(labelCurrent)
        header.addSubview(buttonNext)
        header.addSubview(segmentedControl)
        header.addSubview(labelOutcome)
        header.addSubview(labelIncome)
        header.addSubview(labelTotal)
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints({
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        })
        buttonPrevious.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        buttonNext.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        labelCurrent.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(buttonPrevious)
        }
        segmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16 + 50)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16).priority(999)
        }
        labelOutcome.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(segmentedControl)
        }
        labelIncome.snp.makeConstraints {
            $0.top.equalTo(labelOutcome.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(segmentedControl)
        }
        labelTotal.snp.makeConstraints {
            $0.top.equalTo(labelIncome.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(segmentedControl)
            $0.bottom.equalToSuperview()
        }

        header.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
        }
        labelEmpty.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.leading.trailing.equalTo(header)
            $0.height.equalTo(200)
        }
        header.setNeedsLayout()
        header.layoutIfNeeded()
    }

    func bind(reactor: ListViewReactor) {
        rx.viewWillAppear
            .withLatestFrom(segmentedControl.rx.selectedSegmentIndex)
            .map(Transaction.init)
            .filterNil()
            .map(Reactor.Action.refresh)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        buttonPrevious.rx.tap
            .map { Reactor.Action.previous }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        buttonNext.rx.tap
            .map { Reactor.Action.next }
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

        reactor.state
            .map { "지출: \($0.totalOutcome.currencyFormattedText)" }
            .bind(to: labelOutcome.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { "수입: \($0.totalIncome.currencyFormattedText)" }
            .bind(to: labelIncome.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.totalIncome - $0.totalOutcome }
            .map { "합계: \($0.currencyFormattedText)" }
            .bind(to: labelTotal.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isEmptyLabelHidden }
            .bind(to: labelEmpty.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.state
            .map { "\($0.year)년 \($0.month)월" }
            .bind(to: labelCurrent.rx.text)
            .disposed(by: disposeBag)
    }

}
