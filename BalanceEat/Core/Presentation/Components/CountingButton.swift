//
//  CountingButton.swift
//  BalanceEat
//
//  Created by 김견 on 9/29/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CountingButton: UIView {

    private let disposeBag = DisposeBag()
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemGray6
        button.tintColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        return button
    }()
    
    let tap = PublishRelay<Void>()
    
    init(title: String? = nil, image: UIImage? = nil) {
        super.init(frame: .zero)
        setupView()
        configure(title: title, image: image)
        bindButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.center.equalToSuperview()
        }
    }
    
    func configure(title: String? = nil, image: UIImage? = nil) {
        if let title = title {
            button.setTitle(title, for: .normal)
            button.setImage(nil, for: .normal)
        } else if let image = image {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            button.setTitle(nil, for: .normal)
        }
    }
    
    private func bindButton() {
        button.rx.tap
            .bind(to: tap)
            .disposed(by: disposeBag)
    }
}
