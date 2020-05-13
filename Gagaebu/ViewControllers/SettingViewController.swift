//
//  SettingViewController.swift
//  Gagaebu
//
//  Created by Soso on 12/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import ReactorKit
import ReusableKit
import RxSwift
import AcknowList

class SettingViewController: BaseViewController, View {
    struct Reusable {
        static let settingCell = ReusableCell<SettingCell>()
    }

    let tableView = UITableView().then {
        $0.rowHeight = 44
        $0.register(Reusable.settingCell)
    }

    init(reactor: SettingViewReactor) {
        super.init()

        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Setting"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)

        tableView.tableFooterView = UIView()
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }

    func bind(reactor: SettingViewReactor) {
        reactor.state
            .map { $0.items }
            .asObservable()
            .bind(to: tableView.rx.items(Reusable.settingCell)) { (row, item, cell) in
                switch item {
                case .appstore(let reactor),
                     .acknowledgements(let reactor),
                     .version(let reactor):
                    cell.reactor = reactor
                }
            }.disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let item = reactor.currentState.items[indexPath.row]
                switch item {
                case .appstore:
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/1509453738"),
                        UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                case .acknowledgements:
                    let vc = AcknowListViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }).disposed(by: disposeBag)
    }

}
