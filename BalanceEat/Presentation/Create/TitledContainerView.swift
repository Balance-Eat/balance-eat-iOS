//
//  TitledContainerView.swift
//  BalanceEat
//
//  Created by 김견 on 7/17/25.
//

import UIKit
import SnapKit

final class TitledContainerView: UIView {
    private let title: String
    private let backgroundView = HomeMenuContentView()
    private let contentView: UIView
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .bodyStatusCardNumber
        return label
    }()
    
    init(title: String, contentView: UIView) {
        self.title = title
        self.contentView = contentView
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(contentView)
        
        contentView.isUserInteractionEnabled = true
        
        titleLabel.text = title
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().offset(-20)
        }
    }
}
