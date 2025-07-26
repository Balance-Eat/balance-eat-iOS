//
//  HomeMenuContentView.swift
//  BalanceEat
//
//  Created by 김견 on 7/13/25.
//

import UIKit
import SnapKit

final class HomeMenuContentView: UIView {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        self.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBackgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }
}
