//
//  BottomNavigationBarTabButton.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class BottomNavigationBarTabButton: UIView {
    private let iconImage: UIImage
    private let title: String
    
    private var isSelected: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isSelectedObservable: Observable<Bool> {
        return isSelected.asObservable()
    }
    private let tap: PublishSubject<Void> = .init()
    var tapObservable: Observable<Void> {
        return tap.asObservable()
    }
    private let disposeBag = DisposeBag()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .gray
        return label
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        return stackView
    }()
    
    init(iconImage: UIImage, title: String) {
        self.iconImage = iconImage
        self.title = title
        super.init(frame: .zero)
        
        setUpView()
        setUpBinding()
        updateUI(selected: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        iconImageView.image = iconImage
        titleLabel.text = title
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        stackView.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(48)
            make.center.equalToSuperview()
        }
    }
    
    private func setUpBinding() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                let newValue = !self.isSelected.value
                self.isSelected.accept(newValue)
            })
            .bind { [weak self] _ in
                self?.tap.onNext(())
                
            }
            .disposed(by: disposeBag)
    }
    
    func bindSelected(_ isSelected: Observable<Bool>) {
        isSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selected in
                self?.updateUI(selected: selected)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(selected: Bool) {
        self.iconImageView.image = self.iconImage.withRenderingMode(.alwaysTemplate)
        self.iconImageView.tintColor = selected ? .green : .lightGray
        self.titleLabel.textColor = selected ? .green : .lightGray
    }
}
