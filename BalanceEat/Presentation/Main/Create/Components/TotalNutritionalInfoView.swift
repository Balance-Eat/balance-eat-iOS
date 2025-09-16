//
//  TotalNutritionalInfoView.swift
//  BalanceEat
//
//  Created by 김견 on 7/28/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TotalNutritionalInfoView: UIView {
    private let title: String
    
    let calorieRelay = BehaviorRelay<Double>(value: 0)
    let carbonRelay = BehaviorRelay<Double>(value: 0)
    let proteinRelay = BehaviorRelay<Double>(value: 0)
    let fatRelay = BehaviorRelay<Double>(value: 0)
    
    private let disposeBag = DisposeBag()
    
    private let calorieInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .calorie)
    private let carbonInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .carbon)
    private let proteinInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .protein)
    private let fatInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .fat)
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.backgroundColor = .lightGray.withAlphaComponent(0.1)
        self.layer.cornerRadius = 8
                
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.addArrangedSubview(calorieInfoView)
        stackView.addArrangedSubview(carbonInfoView)
        stackView.addArrangedSubview(proteinInfoView)
        stackView.addArrangedSubview(fatInfoView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        calorieRelay
            .bind(to: calorieInfoView.valueRelay)
            .disposed(by: disposeBag)
        
        carbonRelay
            .bind(to: carbonInfoView.valueRelay)
            .disposed(by: disposeBag)
        
        proteinRelay
            .bind(to: proteinInfoView.valueRelay)
            .disposed(by: disposeBag)
        
        fatRelay
            .bind(to: fatInfoView.valueRelay)
            .disposed(by: disposeBag)
    }
}
