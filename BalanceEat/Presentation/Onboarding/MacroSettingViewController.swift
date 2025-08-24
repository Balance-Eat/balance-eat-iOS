//
//  MacroSettingViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MacroSettingViewController: UIViewController {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "영양소 비율을 설정하세요."
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    init () {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        
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
    }
    
    private func setUpBinding() {
        TutorialPageViewModel.shared.targetCaloriesObservable
            .map { "일일 \($0)kcal 기준으로\n 탄수화물, 단백질, 지방 비율을 결정합니다." }
            .bind(to: subtitleLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
