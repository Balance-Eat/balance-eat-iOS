//
//  MealTimePickerView.swift
//  BalanceEat
//
//  Created by 김견 on 7/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MealTimePickerView: UIView {
    private var selectedItemView: MealTimePickerItem?
    private let timePickerStackView = UIStackView()
    
    private let inputTimeView = InputTimeView()
    
    let selectedMealTimeRelay: BehaviorRelay<MealType>
    let timeRelay: BehaviorRelay<Date> = .init(value: Date())
    
    private var itemViews: [MealType: MealTimePickerItem] = [:]
    private let disposeBag = DisposeBag()
    
    init(selectedMealTimeRelay: BehaviorRelay<MealType>) {
        self.selectedMealTimeRelay = selectedMealTimeRelay
        super.init(frame: .zero)
        setUpView()
        setBinding()
        setUpItems()
        updateSelectedItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.isUserInteractionEnabled = true
        timePickerStackView.axis = .horizontal
        timePickerStackView.spacing = 10
        timePickerStackView.distribution = .fillEqually
        
        let separatorView = UIView()
        separatorView.backgroundColor = .systemGray4
        
        let mainStackView = UIStackView(arrangedSubviews: [timePickerStackView, separatorView, inputTimeView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        
        addSubview(mainStackView)
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setBinding() {
        selectedMealTimeRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] mealTime in
                self?.updateSelectedItem()
            })
            .disposed(by: disposeBag)
        
        inputTimeView.timeRelay
            .bind(to: timeRelay)
            .disposed(by: disposeBag)
    }
    
    private func setUpItems() {
        for mealType in [MealType.breakfast, .lunch, .dinner, .snack] {
            let item = MealTimePickerItem(mealType: mealType, isSelected: mealType == selectedMealTimeRelay.value)
            itemViews[mealType] = item
            timePickerStackView.addArrangedSubview(item)
        
            
            item.tapObservable
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    if self.selectedMealTimeRelay.value != mealType {
                        self.selectedMealTimeRelay.accept(mealType)
                    } else {
                        self.updateSelectedItem()
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func updateSelectedItem() {
        for (mealTime, itemView) in itemViews {
            let isCurrent = (mealTime == selectedMealTimeRelay.value)
            itemView.setSelected(isCurrent)
            if isCurrent {
                selectedItemView = itemView
            }
        }
    }
    
    func setTime(_ date: Date) {
        inputTimeView.setTime(date)
    }
}

final class MealTimePickerItem: UIView {
    private let mealType: MealType
    private var isSelected: Bool = false
    private var titleText: String {
        switch mealType {
        case .breakfast:
            "아침"
        case .lunch:
            "점심"
        case .dinner:
            "저녁"
        case .snack:
            "간식"
        }
    }
    private let tap: PublishSubject<Void> = .init()
    var tapObservable: Observable<Void> {
        tap.asObservable()
    }
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .mealTimePickerTitle
        return label
    }()
    
    init(mealType: MealType, isSelected: Bool) {
        self.mealType = mealType
        self.isSelected = isSelected
        super.init(frame: .zero)
        
        setUpView()
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.alpha = 0.6
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.alpha = 1.0
    }
  
    private func setUpView() {
        self.isUserInteractionEnabled = true
        titleLabel.isUserInteractionEnabled = false
        
        self.backgroundColor = .homeScreenBackground
        
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.mealTimePickerBorder.cgColor
        
        titleLabel.text = titleText
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    private func setUpBinding() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.tap.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        self.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.mealTimePickerBorder.cgColor
        self.titleLabel.textColor = selected ? .systemBlue : .mealTimePickerTitle
    }
}

final class InputTimeView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "시간 입력"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.borderStyle = .line
        textField.textAlignment = .center
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        textField.textColor = .black
        return textField
    }()
    
    private let timePicker = UIDatePicker()
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()
    
    private let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
    
    let timeRelay = BehaviorRelay<Date>(value: Date())
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "ko_KR")
        
        toolbar.items = [doneButton]
        
        textField.inputView = timePicker
        textField.inputAccessoryView = toolbar
        
        [label, textField].forEach(addSubview(_:))
      
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.top.equalTo(label.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setBinding() {
        let formatter = DateFormatter()
        formatter.dateFormat = "a hh:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        
        timePicker.rx.date
            .bind(to: timeRelay)
            .disposed(by: disposeBag)
        
        timePicker.rx.date
            .map { formatter.string(from: $0) }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                textField.resignFirstResponder()
            }
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                textField.layer.borderColor = UIColor.systemBlue.cgColor
            })
            .disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                textField.layer.borderColor = UIColor.lightGray.cgColor
            })
            .disposed(by: disposeBag)
    }
    
    func setTime(_ date: Date) {
        timePicker.setDate(date, animated: false)
        timePicker.sendActions(for: .valueChanged)
    }
}
