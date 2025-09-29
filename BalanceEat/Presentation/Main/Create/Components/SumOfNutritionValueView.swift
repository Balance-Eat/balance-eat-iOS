//
//  TotalNutritionValueView.swift
//  BalanceEat
//
//  Created by 김견 on 9/16/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SumOfNutritionValueView: UIView {
    let calorieRelay = BehaviorRelay<Double>(value: 0)
    let carbonRelay = BehaviorRelay<Double>(value: 0)
    let proteinRelay = BehaviorRelay<Double>(value: 0)
    let fatRelay = BehaviorRelay<Double>(value: 0)
    
    private let disposeBag = DisposeBag()
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chart.pie"))
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let calorieInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .calorie)
    private let carbonInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .carbon)
    private let proteinInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .protein)
    private let fatInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .fat)
    
    
    
    init(title: String, subTitle: String? = nil) {
        titleLabel.text = title
        if let subTitle = subTitle {
            self.subTitleLabel.text = subTitle
        } else {
            subTitleLabel.isHidden = true
        }
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        let containerView = BalanceEatContentView()
        
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [calorieInfoView, carbonInfoView, proteinInfoView, fatInfoView].forEach {
            $0.cornerRadius = 8
            $0.valueTextSize = 24
            $0.titleTextSize = 12
        }
        
        let titleStackView = UIStackView(arrangedSubviews: [titleImageView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 8
        
        let nutritionFirstStackView = UIStackView(arrangedSubviews: [calorieInfoView, carbonInfoView])
        nutritionFirstStackView.axis = .horizontal
        nutritionFirstStackView.spacing = 12
        nutritionFirstStackView.distribution = .fillEqually
        
        let nutritionSecondStackView = UIStackView(arrangedSubviews: [proteinInfoView, fatInfoView])
        nutritionSecondStackView.axis = .horizontal
        nutritionSecondStackView.spacing = 12
        nutritionSecondStackView.distribution = .fillEqually
        
        let nutritionMainStackView = UIStackView(arrangedSubviews: [nutritionFirstStackView, nutritionSecondStackView])
        nutritionMainStackView.axis = .vertical
        nutritionMainStackView.spacing = 12
        
        [titleStackView, subTitleLabel, nutritionMainStackView].forEach(containerView.addSubview)
        
        titleStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleStackView)
        }
        
        nutritionMainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
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
