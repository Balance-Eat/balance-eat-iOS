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
        config.title = title
        config.image = image?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = style.backgroundColor
        config.baseForegroundColor = style.titleColor
        
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        
        configuration = config
        
        tintColor = .white
        layer.cornerRadius = 12
        clipsToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
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
    
    override var isEnabled: Bool {
        didSet {
            guard let style = style else { return }
            
            if isEnabled {
                backgroundColor = style.backgroundColor
                setTitleColor(style.titleColor, for: .normal)
            } else {
                backgroundColor = .lightGray.withAlphaComponent(0.6)
                setTitleColor(.white, for: .disabled)
            }
        }
    }
}

