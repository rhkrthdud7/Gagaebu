//
//  BorderedTextField.swift
//  Gagaebu
//
//  Created by Soso on 04/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit

class BorderedTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    func setupViews() {
        let viewInset = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 15, height: 0)))
        leftView = viewInset
        leftViewMode = .always
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 15)
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
    }

}
