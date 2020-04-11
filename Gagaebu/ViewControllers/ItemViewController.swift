//
//  ItemViewController.swift
//  Gagaebu
//
//  Created by Soso on 21/03/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import RealmSwift
import ReactorKit
import RxSwift
import RxCocoa
import RxOptional
import RxGesture
import SnapKit
import Then

class ItemViewController: BaseViewController, ReactorKit.View {
    lazy var textFieldDate = InputTextField().then {
        $0.inputView = datePicker
    }
    let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.date = Date()
    }
    let textFieldCost = InputTextField().then {
        $0.keyboardType = .numberPad
    }
    let textFieldTitle = InputTextField()
    let buttonAdd = UIButton(type: .system)

    init(reactor: ItemViewReactor) {
        super.init()

        self.reactor = reactor
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func setup() {
        view.backgroundColor = .systemBackground

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let viewContent = UIView().then {
            $0.backgroundColor = .clear
        }
        scrollView.addSubview(viewContent)
        viewContent.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }

        let labelDate = UILabel().then {
            $0.text = "날짜"
        }
        viewContent.addSubview(labelDate)
        labelDate.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
        }
        viewContent.addSubview(textFieldDate)
        textFieldDate.snp.makeConstraints {
            $0.top.equalTo(labelDate.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        let labelCost = UILabel().then {
            $0.text = "금액"
        }
        viewContent.addSubview(labelCost)
        labelCost.snp.makeConstraints {
            $0.top.equalTo(textFieldDate.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        viewContent.addSubview(textFieldCost)
        textFieldCost.snp.makeConstraints {
            $0.top.equalTo(labelCost.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        let labelTitle = UILabel().then {
            $0.text = "제목"
        }
        viewContent.addSubview(labelTitle)
        labelTitle.snp.makeConstraints {
            $0.top.equalTo(textFieldCost.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        viewContent.addSubview(textFieldTitle)
        textFieldTitle.snp.makeConstraints {
            $0.top.equalTo(labelTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        viewContent.addSubview(buttonAdd)
        buttonAdd.snp.makeConstraints {
            $0.top.equalTo(textFieldTitle.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }

    func bind(reactor: ItemViewReactor) {
        view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            }).disposed(by: disposeBag)

        datePicker.rx.controlEvent(.valueChanged)
            .withLatestFrom(datePicker.rx.date)
            .map(Reactor.Action.updateDate)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        textFieldCost.rx.controlEvent(.editingChanged)
            .withLatestFrom(textFieldCost.rx.text.orEmpty)
            .map(Reactor.Action.updateCost)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        textFieldTitle.rx.controlEvent(.editingChanged)
            .withLatestFrom(textFieldTitle.rx.text.orEmpty)
            .distinctUntilChanged()
            .map(Reactor.Action.updateTitle)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        buttonAdd.rx.tap
            .map { Reactor.Action.pressSubmit }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.asObservable().map { $0.title }
            .distinctUntilChanged()
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        reactor.state.asObservable()
            .map { $0.itemTitle }
            .distinctUntilChanged()
            .bind(to: textFieldTitle.rx.text)
            .disposed(by: disposeBag)

        reactor.state.asObservable()
            .map { "\($0.itemCost)" }
            .bind(to: textFieldCost.rx.text)
            .disposed(by: disposeBag)

        reactor.state.asObservable()
            .map { $0.isSubmitButtonEnabled }
            .bind(to: buttonAdd.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state.asObservable()
            .map { $0.buttonTitle }
            .bind(to: buttonAdd.rx.title())
            .disposed(by: disposeBag)

        reactor.state.asObservable()
            .map { $0.itemTitle }
            .bind(to: textFieldTitle.rx.text)
            .disposed(by: disposeBag)

        reactor.state.asObservable()
            .map { $0.shouldPop }
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)

        let dateObservable = reactor.state.asObservable()
            .map { $0.itemDate }
            .distinctUntilChanged()
        dateObservable
            .bind(to: datePicker.rx.date)
            .disposed(by: disposeBag)
        dateObservable
            .map { $0.dateFormattedText }
            .bind(to: textFieldDate.rx.text)
            .disposed(by: disposeBag)
    }
}
