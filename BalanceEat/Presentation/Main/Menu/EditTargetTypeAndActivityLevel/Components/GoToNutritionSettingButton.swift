//
//  GoToNutritionSettingButton.swift
//  BalanceEat
//
//  Created by 김견 on 11/3/25.
//

import UIKit

final class GoToNutritionSettingButton: TitledButton {
    init() {
        let title = "섭취 목표 설정"
        let image = UIImage(systemName: "target")
        let buttonStyle: TitledButtonStyle = .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemGreen, .systemGreen.withAlphaComponent(0.5)]
        )
        super.init(title: title, image: image, style: buttonStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
