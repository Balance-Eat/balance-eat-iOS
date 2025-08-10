//
//  SelectableTitledButton.swift
//  BalanceEat
//
//  Created by 김견 on 8/10/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SelectableTitledButton: UIView {
    private var style: TitledButtonStyle?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let isSelectedRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    init(title: String, style: TitledButtonStyle) {
        super.init(frame: .zero)
        self.style = style
        setUpView(title: title)
        setupTapGesture()
        bindSelectedState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(title: String) {
        titleLabel.text = title
        titleLabel.textColor = style?.titleColor
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.layer.cornerRadius = 12
        self.backgroundColor = style?.backgroundColor
        
        if let borderColor = style?.borderColor {
            self.layer.borderWidth = 1
            self.layer.borderColor = borderColor.cgColor
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.greaterThanOrEqualTo(80)
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.isSelectedRelay.accept(!self.isSelectedRelay.value)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindSelectedState() {
        isSelectedRelay
            .bind { [weak self] isSelected in
                guard let self = self else { return }
                if isSelected {
                    UIView.animate(withDuration: 0.25) {
                        self.backgroundColor = .systemBlue.withAlphaComponent(0.05)
                        self.titleLabel.textColor = .systemBlue
                        self.layer.borderColor = UIColor.systemBlue.cgColor
                    }
                } else {
                    UIView.animate(withDuration: 0.25) {
                        self.backgroundColor = self.style?.backgroundColor
                        self.titleLabel.textColor = self.style?.titleColor
                        self.layer.borderColor = self.style?.borderColor?.cgColor ?? UIColor.clear.cgColor
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
