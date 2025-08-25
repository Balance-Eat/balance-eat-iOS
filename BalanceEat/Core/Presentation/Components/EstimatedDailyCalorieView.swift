//
//  EstimatedDailyCalorieView.swift
//  BalanceEat
//
//  Created by 김견 on 8/25/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EstimatedDailyCalorieView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .estimatedDailyCalorie
        label.text = "예상 일일 소모 칼로리"
        return label
    }()
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .estimatedDailyCalorie
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .estimatedDailyCalorie.withAlphaComponent(0.6)
        label.text = "기초대사량 + 활동량을 고려한 총 소모 칼로리입니다"
        return label
    }()
    
    let calorieRelay: PublishRelay<Int> = PublishRelay<Int>()
    let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
        setUpBinding()
    }
    
    required  init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func formatNumberWithComma(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    private func setCalorieLabelText(_ calorie: String) {
        let fullText = "\(calorie) kcal"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let numberRange = NSRange(location: 0, length: calorie.count)
        let unitRange = NSRange(location: calorie.count + 1, length: 4)
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24, weight: .bold), range: numberRange)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .bold), range: unitRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.estimatedDailyCalorie, range: NSRange(location: 0, length: fullText.count))
        
        calorieLabel.attributedText = attributedString
    }
    
    private func setUpView() {
        let spacer = UIView()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, spacer, calorieLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        spacer.snp.makeConstraints { make in
            make.height.equalTo(4)
        }
        
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.estimatedDailyCalorie.withAlphaComponent(0.2).cgColor
    }
    
    private func setUpBinding() {
        calorieRelay.subscribe(onNext: { [weak self] calorie in
            guard let self = self else { return }
            self.setCalorieLabelText(self.formatNumberWithComma(calorie))
        })
        .disposed(by: disposeBag)
    }
}
