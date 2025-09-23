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
}
