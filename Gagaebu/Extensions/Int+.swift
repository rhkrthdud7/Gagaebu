//
//  Int+.swift
//  Gagaebu
//
//  Created by Soso on 11/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation

extension Int {
    var currencyFormattedText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let string = formatter.string(from: NSNumber(value: self))!
        return "\(string)원"
    }

}
