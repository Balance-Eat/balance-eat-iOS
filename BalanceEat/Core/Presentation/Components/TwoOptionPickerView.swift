//
//  TwoOptionPickerView.swift
//  BalanceEat
//
//  Created by 김견 on 9/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum TwoOptionPickerItem {
    case first, second
}

final class TwoOptionPickerView: UIView {
    
    private let firstButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let secondButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    let selectedOption = BehaviorRelay<TwoOptionPickerItem>(value: .first)
    private let disposeBag = DisposeBag()
    
    init(firstText: String, secondText: String) {
        super.init(frame: .zero)
        firstButton.setTitle(firstText, for: .normal)
        secondButton.setTitle(secondText, for: .normal)
        
        setUpView()
        setBinding()
        updateUI(animated: false)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setUpView() {
        self.layer.cornerRadius = 18
        self.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        [firstButton, secondButton].forEach { addSubview($0) }
        
        firstButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(6)
            make.width.equalTo(secondButton)
        }
        secondButton.snp.makeConstraints { make in
            make.leading.equalTo(firstButton.snp.trailing).offset(8)
            make.top.trailing.bottom.equalToSuperview().inset(6)
        }
    }
    
    private func setBinding() {
        func addTapAnimation(to button: UIButton, item: TwoOptionPickerItem) {
            button.rx.tap
                .do(onNext: { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                        button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    }) { _ in
                        UIView.animate(withDuration: 0.1) {
                            button.transform = .identity
                        }
                    }
                })
                .map { item }
                .bind(to: selectedOption)
                .disposed(by: disposeBag)
        }
        
        addTapAnimation(to: firstButton, item: .first)
        addTapAnimation(to: secondButton, item: .second)
        
        selectedOption
            .subscribe(onNext: { [weak self] _ in
                self?.updateUI(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(animated: Bool) {
        let firstSelected = selectedOption.value == .first
        let secondSelected = selectedOption.value == .second
        
        let update = {
            self.firstButton.backgroundColor = firstSelected ? UIColor.systemBlue : .white
            self.firstButton.setTitleColor(firstSelected ? .white : .systemBlue, for: .normal)
            self.firstButton.layer.shadowOpacity = firstSelected ? 0.25 : 0.1
            
            self.secondButton.backgroundColor = secondSelected ? UIColor.systemBlue : .white
            self.secondButton.setTitleColor(secondSelected ? .white : .systemBlue, for: .normal)
            self.secondButton.layer.shadowOpacity = secondSelected ? 0.25 : 0.1
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: update)
        } else {
            update()
        }
    }
}
