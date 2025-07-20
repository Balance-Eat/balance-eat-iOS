//
//  SearchInputField.swift
//  BalanceEat
//
//  Created by 김견 on 7/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchInputField: UIView {
    private let placeholder: String
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .label
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    
    var textObservable: Observable<String?> {
        textField.rx.text.asObservable()
    }
    
    let searchTap = PublishRelay<Void>()
    
    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.textField.placeholder = placeholder
        
        self.layer.cornerRadius = 22
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.mealTimePickerBorder.cgColor
        
        self.addSubview(textField)
        self.addSubview(searchIcon)
        
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(searchIcon.snp.left).offset(-8)
        }
        
        searchIcon.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        let tapGesture = UITapGestureRecognizer()
        searchIcon.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.searchTap.accept(())
            }
            .disposed(by: disposeBag)
    }
}
