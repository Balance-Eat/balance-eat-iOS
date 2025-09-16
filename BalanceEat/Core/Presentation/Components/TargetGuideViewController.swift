//
//  TargetGuideViewController.swift
//  BalanceEat
//
//  Created by 김견 on 9/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TargetGuideViewController: UIViewController {
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.05)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.4).cgColor
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setUpPopupContent()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func setUpPopupContent() {
        view.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.addSubview(mainStackView)
        contentView.addSubview(closeButton)
        
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(60)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        let titleImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "info.circle"))
            imageView.tintColor = .systemBlue
            return imageView
        }()
        
        titleImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .systemBlue
            label.text = "건강한 목표 설정 가이드"
            return label
        }()
        
        let titleStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleImageView, titleLabel])
            stackView.axis = .horizontal
            stackView.spacing = 8
            return stackView
        }()
        
        let smiTargetGuideComponentView = TargetGuideComponentView(
            title: "골격근량",
            maleAmount: "40-50%",
            femaleAmount: "36-42%",
            significant: "* 체중 대비 비율 기준"
        )
        
        let fatPercentageTargetGuideComponentView = TargetGuideComponentView(
            title: "체지방률",
            maleAmount: "10-20%",
            femaleAmount: "16-25%"
        )
    
        let psLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.textColor = .systemBlue
            label.numberOfLines = 0
            
            let fullText = "측정 권장 : 인바디, DEXA 스캔 등 전문 기기 이용"
            let attributedString = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.systemBlue
                ]
            )
            
            if let range = fullText.range(of: "측정 권장") {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: nsRange)
            }
            
            label.attributedText = attributedString
            return label
        }()

        [titleStackView, smiTargetGuideComponentView, fatPercentageTargetGuideComponentView, psLabel].forEach(mainStackView.addArrangedSubview)
    }
    
    private func setBinding() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] gesture in
                guard let self = self else { return }
                let location = gesture.location(in: self.view)
                
                if self.contentView.frame.contains(location) { return }
                
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

final class TargetGuideComponentView: UIView {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let maleTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.text = "남성 :"
        return label
    }()
    
    private let maleAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let femaleTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.text = "여성 :"
        return label
    }()
    
    private let femaleAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let significantLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemBlue
        return label
    }()
    
    init(title: String, maleAmount: String, femaleAmount: String, significant: String? = nil) {
        titleLabel.text = title
        maleAmountLabel.text = maleAmount
        femaleAmountLabel.text = femaleAmount
        if let significant = significant {
            self.significantLabel.text = "\(significant)"
        } else {
            self.significantLabel.isHidden = true
        }
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        backgroundColor = .white
        
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        let maleStackView: UIStackView = {
            let spacer = UIView()
            let stackView = UIStackView(arrangedSubviews: [maleTitleLabel, spacer, maleAmountLabel])
            stackView.axis = .horizontal
            return stackView
        }()
        
        let femaleStackView: UIStackView = {
            let spacer = UIView()
            let stackView = UIStackView(arrangedSubviews: [femaleTitleLabel, spacer, femaleAmountLabel])
            stackView.axis = .horizontal
            return stackView
        }()
        
        [titleLabel, maleStackView, femaleStackView, significantLabel].forEach(mainStackView.addArrangedSubview)
    }
}
