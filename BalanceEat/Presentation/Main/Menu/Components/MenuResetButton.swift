//
//  MenuResetButton.swift
//  BalanceEat
//
//  Created by 김견 on 10/26/25.
//

import UIKit

final class MenuResetButton: TitledButton {
    init() {
        let title = "원래 값으로 되돌리기"
        let image = UIImage(systemName: "arrow.clockwise")
        let buttonStyle: TitledButtonStyle = .init(
            backgroundColor: .white,
            titleColor: .black,
            borderColor: .lightGray.withAlphaComponent(0.6),
            gradientColors: nil
        )
        super.init(title: title, image: image, style: buttonStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

