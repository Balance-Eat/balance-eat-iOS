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

class BasicInfoViewController: UIViewController {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
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
    
    private var gender: BehaviorRelay<Gender> = BehaviorRelay(value: .none)
    private var ageText: Observable<String?> = Observable.just(nil)
    private var heightText: Observable<String?> = Observable.just(nil)
    private var weightText: Observable<String?> = Observable.just(nil)
    
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
        view.backgroundColor = .homeScreenBackground
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(mainStackView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        let maleButton = SelectableTitledButton(
            title: "남성",
            style: .init(backgroundColor: .white, titleColor: .black, borderColor: .lightGray.withAlphaComponent(0.4))
        )
        let femaleButton = SelectableTitledButton(
            title: "여성",
            style: .init(backgroundColor: .white, titleColor: .black, borderColor: .lightGray.withAlphaComponent(0.4))
        )
        let genderButtons = [maleButton, femaleButton]
        
        for button in genderButtons {
            button.isSelectedRelay
                .subscribe(onNext: { [weak self, weak button] isSelected in
                    guard let self = self, let button = button else { return }
                    if isSelected {
                        genderButtons.forEach {
                            if $0 != button { $0.isSelectedRelay.accept(false) }
                        }
                        self.gender.accept(button === maleButton ? .male : .female)
                    } else {
                        self.gender.accept(.none)
                    }
                })
                .disposed(by: disposeBag)
        }
        
        let genderStackView = UIStackView(arrangedSubviews: genderButtons)
        genderStackView.axis = .horizontal
        genderStackView.distribution = .fillEqually
        genderStackView.spacing = 8
        
        let genderInputView = TitledInputUserInfoView(title: "성별", inputView: genderStackView)
        let ageInputField = InputFieldWithIcon(icon: UIImage(systemName: "calendar.and.person")!, placeholder: "나이를 입력해주세요.", unit: "세", isAge: true)
        let ageInputView = TitledInputUserInfoView(title: "나이", inputView: ageInputField)
        self.ageText = ageInputField.textObservable
        
        let heightInputField = InputFieldWithIcon(icon: UIImage(systemName: "ruler")!, placeholder: "신장을 입력해주세요.", unit: "cm")
        let heightInputView = TitledInputUserInfoView(title: "신장", inputView: heightInputField)
        self.heightText = heightInputField.textObservable
        
        let weightInputField = InputFieldWithIcon(icon: UIImage(systemName: "scalemass")!, placeholder: "체중을 입력해주세요.", unit: "kg")
        let weightInputView = TitledInputUserInfoView(title: "체중", inputView: weightInputField)
        self.weightText = weightInputField.textObservable
        
        let nextButton = TitledButton(
            title: "다음",
            style: .init(
                backgroundColor: .systemBlue,
                titleColor: .white,
                borderColor: nil
            )
        )
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.inputCompleted.accept(())
            })
            .disposed(by: disposeBag)
        
        [genderInputView, ageInputView, heightInputView, weightInputView, nextButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        Observable.combineLatest(gender, ageText, heightText, weightText) { gender, age, height, weight -> Bool in
            guard let age = age, let height = height, let weight = weight else {
                return false
            }
            return !(gender == .none) && !age.isEmpty && !height.isEmpty && !weight.isEmpty
        }
        .bind(to: nextButton.rx.isEnabled)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(gender, ageText, heightText, weightText)
            .subscribe(onNext: { gender, age, height, weight in
                var data = TutorialPageViewModel.shared.dataRelay.value
                data.gender = gender
                data.age = Int(age ?? "")
                data.height = Double(height ?? "")
                data.weight = Double(weight ?? "")
                TutorialPageViewModel.shared.dataRelay.accept(data)
            })
            .disposed(by: disposeBag)

    }
}

final class InputFieldWithIcon: UIView {
    private let icon: UIImage?
    private let placeholder: String = ""
    private let unit: String?
    private var isAge: Bool = false
    private var isFat: Bool = false
    
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
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        return textField
    }()
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    let disposeBag = DisposeBag()
    var textObservable: Observable<String?> {
        textField.rx.text.asObservable()
    }
    
    init(icon: UIImage? = nil, placeholder: String, unit: String? = nil, isAge: Bool = false, isFat: Bool = false) {
        self.icon = icon
//        self.placeholder = placeholder
        self.unit = unit
        self.isAge = isAge
        self.isFat = isFat
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
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
            make.centerY.equalToSuperview()
            make.width.height.equalTo(icon == nil ? 0 : 20)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.trailing.equalTo(unitLabel.snp.leading).offset(-8)
            make.top.bottom.equalToSuperview().inset(12)
        }
        textField.clipsToBounds = true
        
        unitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16).priority(.high)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setBinding() {
        textField.rx.text.orEmpty
            .map { [weak self] text in
                guard let self = self else { return "" }
                var dotCount = 0
                let filtered = text.filter {
                    if $0 == "." {
                        dotCount += 1
                        if self.isAge {
                            return dotCount <= 0
                        } else {
                            return dotCount <= 1
                        }
                    }
                    return $0.isNumber
                }
                if isAge {
                    return Int(filtered) ?? 0 > 999 ? "999" : filtered
                }
                
                var number = filtered
                if filtered.contains(".") {
                    let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
                    
                    if let firstPart = parts.first, let secondPart = parts.last {
                        if secondPart.count > 1  {
                            number = "\(String(firstPart)).\(String(secondPart).prefix(1))"
                        }
                    }
                }
                if isFat {
                    return Double(number) ?? 0 > 100 ? "100" : String(number)
                }
                
                return Double(number) ?? 0 > 999.9 ? "999.9" : String(number)
            }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)

    }
    
    func setText(_ text: String?) {
        textField.text = text
    }
}
