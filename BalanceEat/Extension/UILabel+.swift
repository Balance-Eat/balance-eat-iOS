//
//  UILabel+.swift
//  BalanceEat
//
//  Created by 김견 on 10/23/25.
//

import UIKit

extension UILabel {
    func setTextWithLineSpacing(_ text: String, lineSpacing: CGFloat = 6) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = self.textAlignment

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: self.font as Any,
            .foregroundColor: self.textColor as Any
        ]
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
