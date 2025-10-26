//
//  TitledButton.swift
//  BalanceEat
//
//  Created by 김견 on 7/28/25.
//

import UIKit
import SnapKit

struct TitledButtonStyle {
    let backgroundColor: UIColor?
    let titleColor: UIColor
    let borderColor: UIColor?
    let gradientColors: [UIColor]?
}

class TitledButton: UIButton {
    
    private var style: TitledButtonStyle?
    private var gradientLayer: CAGradientLayer?
    
    init(title: String, image: UIImage? = nil, style: TitledButtonStyle) {
        super.init(frame: .zero)
        self.style = style
        configure(title: title, image: image, style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String, image: UIImage?, style: TitledButtonStyle) {
        var config = UIButton.Configuration.filled()
        let font = UIFont.systemFont(ofSize: 16, weight: .bold)
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: font, .foregroundColor: style.titleColor]))
        config.image = image?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = style.titleColor
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .medium
        )
        config.background.backgroundColor = .clear
        
        configuration = config
        tintColor = style.titleColor
        layer.cornerRadius = 12
        clipsToBounds = true
        
        if let colors = style.gradientColors {
            applyGradient(colors: colors)
        } else if let bgColor = style.backgroundColor {
            backgroundColor = bgColor
        }
        
        if let borderColor = style.borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        }
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    private func applyGradient(colors: [UIColor]) {
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                alpha = 1.0
                if let colors = style?.gradientColors {
                    applyGradient(colors: colors)
                } else {
                    backgroundColor = style?.backgroundColor
                }
            } else {
                alpha = 1.0
                gradientLayer?.removeFromSuperlayer()
                backgroundColor = .lightGray.withAlphaComponent(0.2)
            }
        }
    }
}
