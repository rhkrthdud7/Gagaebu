//
//  ResizableCollectionView.swift
//  Gagaebu
//
//  Created by Soso on 04/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit

class ResizableCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        invalidateIntrinsicContentSize()
    }

}
