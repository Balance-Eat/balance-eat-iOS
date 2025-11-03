//
//  ResetToRecommendValueButton.swift
//  BalanceEat
//
//  Created by 김견 on 11/3/25.
//

import UIKit

final class ResetToRecommendValueButton: TitledButton {
    init() {
        let title = "추천 세팅으로 초기화"
        let image = UIImage(systemName: "arrow.counterclockwise")
        let buttonStyle: TitledButtonStyle = .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.red.withAlphaComponent(0.5), .red.withAlphaComponent(0.2)]
        )
        super.init(title: title, image: image, style: buttonStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
