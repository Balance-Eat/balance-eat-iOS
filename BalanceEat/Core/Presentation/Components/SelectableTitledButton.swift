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

struct SelectableTitledButtonStyle {
    let backgroundColor: UIColor?
    let titleColor: UIColor
    let borderColor: UIColor?
    let gradientColors: [UIColor]?
    
    let selectedBackgroundColor: UIColor?
    let selectedTitleColor: UIColor
    let selectedBorderColor: UIColor?
    let selectedGradientColors: [UIColor]?
}

final class SelectableTitledButton: UIView {
    private var style: SelectableTitledButtonStyle?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let isSelectedRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    init(title: String, style: SelectableTitledButtonStyle) {
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
                guard let self = self, let style = self.style else { return }
                UIView.animate(withDuration: 0.25) {
                    if isSelected {
                        self.backgroundColor = style.selectedBackgroundColor ?? style.backgroundColor
                        self.titleLabel.textColor = style.selectedTitleColor
                        self.layer.borderColor = style.selectedBorderColor?.cgColor ?? style.borderColor?.cgColor
                        
                        if let colors = style.selectedGradientColors {
                            self.applyGradient(colors: colors)
                        } else {
                            self.removeGradient()
                        }
                    } else {
                        self.backgroundColor = style.backgroundColor
                        self.titleLabel.textColor = style.titleColor
                        self.layer.borderColor = style.borderColor?.cgColor
                        
                        if let colors = style.gradientColors {
                            self.applyGradient(colors: colors)
                        } else {
                            self.removeGradient()
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private var gradientLayer: CAGradientLayer?
    
    private func applyGradient(colors: [UIColor]) {
        removeGradient()
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    private func removeGradient() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
}

