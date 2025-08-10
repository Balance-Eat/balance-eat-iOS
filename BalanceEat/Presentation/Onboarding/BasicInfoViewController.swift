//
//  BasicInfoViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum Gender: String {
    case male = "남성"
    case female = "여성"
    case none = ""
}

class BasicInfoViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "안녕하세요!"
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "맞춤 식단 관리를 위해 기본 정보를 입력해주세요."
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var gender = Gender.none
    
    let inputCompleted = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        let maleButton = SelectableTitledButton(
            title: "남성",
            style: .init(
                backgroundColor: .white,
                titleColor: .black,
                borderColor: .gray
            )
        )
        let femaleButton = SelectableTitledButton(
            title: "여성",
            style: .init(
                backgroundColor: .white,
                titleColor: .black,
                borderColor: .gray
            )
        )
        let genderButtons = [maleButton, femaleButton]
        
        for button in genderButtons {
            button.isSelectedRelay
                .subscribe(onNext: { [weak self, weak button] isSelected in
                    guard let self = self, let button = button else { return }
                    
                    if isSelected {
                        // 선택된 버튼만 true, 나머지 false 처리
                        genderButtons.forEach {
                            if $0 != button {
                                $0.isSelectedRelay.accept(false)
                            }
                        }
                        
                        // gender 값 설정
                        if button === maleButton {
                            self.gender = .male
                        } else if button === femaleButton {
                            self.gender = .female
                        }
                    } else {
                        // 선택 해제 시 gender 초기화
                        self.gender = .none
                    }
                })
                .disposed(by: disposeBag)
        }
        
        let genderStackView = UIStackView(arrangedSubviews: [maleButton, femaleButton])
        genderStackView.distribution = .fillEqually
        genderStackView.spacing = 8
        
        let genderTitledInputView = TitledInputUserInfoView(
            title: "성별",
            inputView: genderStackView
        )
        view.addSubview(genderTitledInputView)
        
        genderTitledInputView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        let ageInputField = InputFieldWithIcon(
            icon: UIImage(systemName: "calendar.and.person") ?? UIImage(),
            placeholder: "나이를 입력해주세요.",
            unit: "세"
        )
        let ageTitledInputView = TitledInputUserInfoView(
            title: "나이",
            inputView: ageInputField
        )
        view.addSubview(ageTitledInputView)
        
        ageTitledInputView.snp.makeConstraints { make in
            make.top.equalTo(genderTitledInputView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}

final class TitledInputUserInfoView: UIView {
    private let title: String
    private let contentView: UIView
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    init(title: String, inputView: UIView) {
        self.title = title
        self.contentView = inputView
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(titleLabel)
        addSubview(contentView)
        
        titleLabel.text = title
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
    }
}

final class InputFieldWithIcon: UIView {
    private let icon: UIImage
    private let placeholder: String
    private let unit: String?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        return imageView
    }()
    private let textField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        return textField
    }()
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    init(icon: UIImage, placeholder: String, unit: String? = nil) {
        self.icon = icon
        self.placeholder = placeholder
        self.unit = unit
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        iconImageView.image = icon
        textField.placeholder = placeholder
        unitLabel.text = unit ?? ""
        
        addSubview(iconImageView)
        addSubview(textField)
        addSubview(unitLabel)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.trailing.equalTo(unitLabel.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        unitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}
