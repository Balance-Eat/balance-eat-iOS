//
//  TitledInputUserInfoView.swift
//  BalanceEat
//
//  Created by 김견 on 8/10/25.
//

import UIKit
import SnapKit

final class TitledInputUserInfoView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let contentView: UIView
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    init(title: String, inputView: UIView) {
        self.contentView = inputView
        super.init(frame: .zero)
        
        titleLabel.text = title
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentView)
    }
}
