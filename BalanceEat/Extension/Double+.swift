//
//  Double+.swift
//  BalanceEat
//
//  Created by 김견 on 9/23/25.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    var displayString: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(self)
    }
}

extension Optional where Wrapped == Double {
    var displayString: String {
        self?.displayString ?? ""
    }
}
