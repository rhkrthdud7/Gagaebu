//
//  InputTextField.swift
//  Gagaebu
//
//  Created by Soso on 04/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit

class InputTextField: UITextField {
    final let height: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    func setupViews() {
        let viewInset = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 15, height: height)))
        leftView = viewInset
        leftViewMode = .always
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: height)
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(rect: bounds)
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
    }

}
