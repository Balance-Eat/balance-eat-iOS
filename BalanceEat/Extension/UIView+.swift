//
//  UIView+.swift
//  BalanceEat
//
//  Created by 김견 on 8/24/25.
//

import UIKit
import SnapKit

extension UIView {
    func wrapBalanceEatContentView() {
        let balanceEatContentView = BalanceEatContentView()
        
        balanceEatContentView.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
}
