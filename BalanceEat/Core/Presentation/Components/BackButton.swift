//
//  BackButton.swift
//  BalanceEat
//
//  Created by 김견 on 8/11/25.
//

import UIKit
import SnapKit

final class BackButton: UIButton {
    var didTapHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }

    private func setUpView() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.baseForegroundColor = .black

        self.configuration = config

        self.configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            if button.isHighlighted {
                self.configuration?.baseForegroundColor = .gray
            } else {
                self.configuration?.baseForegroundColor = .black
            }
        }

        self.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(24)
        }

        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        didTapHandler?()
    }
}

