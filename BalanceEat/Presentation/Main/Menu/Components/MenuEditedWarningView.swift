//
//  MenuEditedWarningView.swift
//  BalanceEat
//
//  Created by 김견 on 10/26/25.
//

import UIKit
import SnapKit

final class MenuEditedWarningView: UIView {
    private let warningImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        imageView.tintColor = .systemRed
        return imageView
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.text = "변경사항이 있습니다. 저장하시겠습니까?"
        return label
    }()
    
    private lazy var warningStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [warningImageView, warningLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(warningStackView)
        
        warningImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        
        warningStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
