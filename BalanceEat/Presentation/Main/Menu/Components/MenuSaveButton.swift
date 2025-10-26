//
//  MenuSaveButton.swift
//  BalanceEat
//
//  Created by 김견 on 10/26/25.
//

import UIKit

final class MenuSaveButton: TitledButton {
    init() {
        let title = "변경사항 저장"
        let image = UIImage(systemName: "square.and.arrow.down")
        let buttonStyle: TitledButtonStyle = .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemBlue, .systemBlue.withAlphaComponent(0.5)]
        )
        super.init(title: title, image: image, style: buttonStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
