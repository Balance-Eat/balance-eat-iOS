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

enum MealTime: String {
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
    case snack = "간식"
}

final class MealTimePickerView: UIView {
    private var selectedItemView: MealTimePickerItem?
    private let stackView = UIStackView()
    
    var selectedMealTime: MealTime {
        didSet {
            updateSelectedItem()
        }
    }
    
    private var itemViews: [MealTime: MealTimePickerItem] = [:]
    private let disposeBag = DisposeBag()
    
    init(selectedMealTime: MealTime) {
        self.selectedMealTime = selectedMealTime
        super.init(frame: .zero)
        setUpView()
        setUpItems()
        updateSelectedItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.isUserInteractionEnabled = true
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
    }
    
    private func setUpItems() {
        for mealTime in [MealTime.breakfast, .lunch, .dinner, .snack] {
            let item = MealTimePickerItem(mealTile: mealTime, isSelected: mealTime == selectedMealTime)
            itemViews[mealTime] = item
            stackView.addArrangedSubview(item)
        
            
            item.tapObservable
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    if self.selectedMealTime != mealTime {
                        self.selectedMealTime = mealTime
                    } else {
                        self.updateSelectedItem()
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func updateSelectedItem() {
        for (mealTime, itemView) in itemViews {
            let isCurrent = (mealTime == selectedMealTime)
            itemView.setSelected(isCurrent)
            if isCurrent {
                selectedItemView = itemView
            }
        }
    }
}

final class MealTimePickerItem: UIView {
    private let mealTime: MealTime
    private var isSelected: Bool = false
    private var titleText: String {
        switch mealTime {
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
    
    init(mealTile: MealTime, isSelected: Bool) {
        self.mealTime = mealTile
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
