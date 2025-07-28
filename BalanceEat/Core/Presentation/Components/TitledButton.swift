//
//  TitledButton.swift
//  BalanceEat
//
//  Created by 김견 on 7/28/25.
//

import UIKit
import SnapKit

struct TitledButtonStyle {
    let backgroundColor: UIColor
    let titleColor: UIColor
    let borderColor: UIColor?
}

final class TitledButton: UIButton {
    
    private var style: TitledButtonStyle?
    
    init(title: String, style: TitledButtonStyle) {
        super.init(frame: .zero)
        self.style = style
        configure(title: title, style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String, style: TitledButtonStyle) {
        setTitle(title, for: .normal)
        setTitleColor(style.titleColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = style.backgroundColor
        
        if let borderColor = style.borderColor {
            layer.borderWidth = 1
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard let style = style else { return }
            backgroundColor = isHighlighted
            ? style.backgroundColor.withAlphaComponent(0.6) 
            : style.backgroundColor
            setTitleColor(isHighlighted
                          ? style.titleColor.withAlphaComponent(0.6)
                          : style.titleColor, for: .normal)
        }
    }
}
