//
//  HomeViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let welcomeBackgroundView = GradientView()
    
    private lazy var welcomeLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        
        let label1 = UILabel()
        label1.text = "안녕하세요, 진문장님!"
        label1.font = .systemFont(ofSize: 24, weight: .bold)
        label1.textColor = .white
        
        let label2 = UILabel()
        label2.text = "오늘도 건강한 하루 되세요 💪"
        label2.font = .systemFont(ofSize: 14, weight: .regular)
        label2.textColor = .white
        
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
        
        return stackView
    }()
    
    private let bodyStatusStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private let nowBodyStatusCardView: BodyStatusCardView = BodyStatusCardView(title: "현재 체성분", weight: 72.53, skeletalMuscleMass: 32.932, bodyFatMass: 15.212312)
    private let targetBodyStatusCardView: BodyStatusCardView = BodyStatusCardView(title: "목표 체성분", weight: -2.6, skeletalMuscleMass: 1.5, bodyFatMass: -3.23, isTarget: true)
    
    private let todayCalorieView: TodayCalorieView = TodayCalorieView(
        currentCalorie: 1420,
        targetCalorie: 2000,
        currentCarbohydrate: 178,
        targetCarbohydrate: 250,
        currentProtein: 95,
        targetProtein: 120,
        currentFat: 45,
        targetFat: 67
    )
    
    private let proteinRemindCardView = ProteinReminderCardView(proteinTime: Calendar.current.date(byAdding: .minute, value: 90, to: Date())!)
    
    private let todayAteMealLogListView: UIView = {
        let contentView = HomeMenuContentView()
        
        let titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.text = "최근 식사 기록"
            titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
            titleLabel.textColor = .bodyStatusCardNumber
            return titleLabel
        }()
        
        let mealLogs: [MealLogView] = [
            MealLogView(icon: .chickenChest, title: "닭가슴살", ateTime: Date(), consumedFoodAmount: 100, consumedCalories: 120, consumedSugars: 0, consumedCarbohydrates: 0, consumedProteins: 23, consumedFats: 1),
            MealLogView(icon: .salad, title: "샐러드", ateTime: Date(), consumedFoodAmount: 100, consumedCalories: 25, consumedSugars: 3, consumedCarbohydrates: 4, consumedProteins: 2, consumedFats: 0)
        ]
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = 0 
            return stackView
        }()
        
        for (index, mealLog) in mealLogs.enumerated() {
            if index > 0 {
                let separator = UIView()
                separator.backgroundColor = .systemGray5

                separator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 1)
                ])
                
                let separatorContainer = UIView()
                separatorContainer.addSubview(separator)
                separator.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.leading.trailing.equalToSuperview().inset(20)
                }

                stackView.addArrangedSubview(separatorContainer)
            }
            
            stackView.addArrangedSubview(mealLog)
        }
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return contentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .homeScreenBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(welcomeBackgroundView)
        contentView.addSubview(bodyStatusStackView)
        contentView.addSubview(todayCalorieView)
        contentView.addSubview(proteinRemindCardView)
        contentView.addSubview(todayAteMealLogListView)
        
        welcomeBackgroundView.addSubview(welcomeLabelStackView)
        welcomeBackgroundView.colors = [
            UIColor.welcomeTitleStartBackground,
            UIColor.welcomeTitleEndBackground
        ]
        
        bodyStatusStackView.addArrangedSubview(nowBodyStatusCardView)
        bodyStatusStackView.addArrangedSubview(targetBodyStatusCardView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        welcomeBackgroundView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        welcomeLabelStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        bodyStatusStackView.snp.makeConstraints { make in
            make.top.equalTo(welcomeBackgroundView.snp.bottom).inset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            
        }
        
        todayCalorieView.snp.makeConstraints { make in
            make.top.equalTo(bodyStatusStackView.snp.bottom).inset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        proteinRemindCardView.snp.makeConstraints { make in
            make.top.equalTo(todayCalorieView.snp.bottom).inset(-40)
            make.leading.trailing.equalToSuperview().inset(20)
//            make.bottom.equalToSuperview().inset(20)
        }
        
        todayAteMealLogListView.snp.makeConstraints { make in
            make.top.equalTo(proteinRemindCardView.snp.bottom).inset(-40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}

class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    var colors: [UIColor] = [.clear, .clear] {
        didSet {
            updateGradientColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradientColors()
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = colors.map { $0.cgColor }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
