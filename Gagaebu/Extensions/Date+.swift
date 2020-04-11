//
//  Date+Extension.swift
//  Gagaebu
//
//  Created by Soso on 04/04/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation

extension Date {
    var dateFormattedText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy.MM.dd (E)"
        return formatter.string(from: self)
    }

}
