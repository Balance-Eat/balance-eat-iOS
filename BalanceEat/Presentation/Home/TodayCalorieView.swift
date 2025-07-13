//
//  TodayCalorieView.swift
//  BalanceEat
//
//  Created by 김견 on 7/13/25.
//

import UIKit
import SnapKit

final class TodayCalorieView: UIView {
    private let currentCalorie: Int
    private let targetCalorie: Int
    private let currentCarbohydrate: Int
    private let targetCarbohydrate: Int
    private let currentProtein: Int
    private let targetProtein: Int
    private let currentFat: Int
    private let targetFat: Int
    
    private let containerView: HomeMenuContentView = HomeMenuContentView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 칼로리"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .bodyStatusCardNumber
        return label
    }()
    
    private lazy var circleProgressView: CircleProgressView = {
        let circleProgressView = CircleProgressView()
        circleProgressView.maxValue = CGFloat(targetCalorie)
        circleProgressView.currentValue = CGFloat(currentCalorie)
        return circleProgressView
    }()
    
    private let nutritionalValueStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    init(currentCalorie: Int, targetCalorie: Int, currentCarbohydrate: Int, targetCarbohydrate: Int, currentProtein: Int, targetProtein: Int, currentFat: Int, targetFat: Int) {
        self.currentCalorie = currentCalorie
        self.targetCalorie = targetCalorie
        self.currentCarbohydrate = currentCarbohydrate
        self.targetCarbohydrate = targetCarbohydrate
        self.currentProtein = currentProtein
        self.targetProtein = targetProtein
        self.currentFat = currentFat
        self.targetFat = targetFat
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(circleProgressView)
        containerView.addSubview(nutritionalValueStackView)
        
        nutritionalValueStackView.addArrangedSubview(createSubNutritionalView(title: "탄수화물", current: currentCarbohydrate, target: targetCarbohydrate))
        nutritionalValueStackView.addArrangedSubview(createSubNutritionalView(title: "단백질", current: currentProtein, target: targetProtein))
        nutritionalValueStackView.addArrangedSubview(createSubNutritionalView(title: "지방", current: currentFat, target: targetFat))
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }
        
        circleProgressView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        nutritionalValueStackView.snp.makeConstraints { make in
            make.top.equalTo(circleProgressView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func createSubNutritionalView(title: String, current: Int, target: Int) -> UIView {
        let containerVIew = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .bodyStatusCartSubtitle

        let currentValueLabel = UILabel()
        currentValueLabel.text = "\(current)g"
        currentValueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        currentValueLabel.textColor = .bodyStatusCardNumber
        
        let targetValueLabel = UILabel()
        targetValueLabel.text = "/ \(target)g"
        targetValueLabel.font = .systemFont(ofSize: 10, weight: .regular)
        targetValueLabel.textColor = .bodyStatusCardUnit

        let stack = UIStackView(arrangedSubviews: [currentValueLabel, targetValueLabel])
        stack.axis = .vertical
        stack.alignment = .center
        
        containerVIew.addSubview(titleLabel)
        containerVIew.addSubview(stack)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-6)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        return containerVIew
    }
}
