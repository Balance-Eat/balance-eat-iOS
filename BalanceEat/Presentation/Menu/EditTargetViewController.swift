//
//  EditTargetViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/18/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class EditTargetViewController: UIViewController {
    private let weightEditTargetItemView = EditTargetItemView(editTargetItemType: .weight)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        view.backgroundColor = .white
        view.addSubview(weightEditTargetItemView)
        
        
        weightEditTargetItemView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

enum EditTargetItemType {
    case weight
    case smi
    case fatPercentage
    
    var title: String {
        switch self {
        case .weight:
            return "체중"
        case .smi:
            return "골격근량"
        case .fatPercentage:
            return "체지방률"
        }
    }
    
    var unit: String {
        switch self {
        case .weight:
            return "kg"
        case .smi:
            return "kg"
        case .fatPercentage:
            return "%"
        }
    }
    
    var systemImage: String {
        switch self {
        case .weight:
            return "scalemass"
        case .smi:
            return "arrowtriangle.up.fill"
        case .fatPercentage:
            return "chart.bar.fill"
        }
    }
}

final class EditTargetItemView: UIView {
    private let editTargetItemType: EditTargetItemType
    
    private let titleIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private var currentText: Observable<String?> = Observable.just(nil)
    private var targetText: Observable<String?> = Observable.just(nil)
    private let disposeBag = DisposeBag()
    
    init(editTargetItemType: EditTargetItemType) {
        self.editTargetItemType = editTargetItemType
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        let mainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [])
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        titleIconImageView.image = UIImage(systemName: editTargetItemType.systemImage)
        titleIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        titleLabel.text = editTargetItemType.title
        
        let titleStackView = UIStackView(arrangedSubviews: [titleIconImageView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 8
        mainStackView.addArrangedSubview(titleStackView)
        
        let currentField = InputFieldWithIcon(placeholder: "", unit: "kg")
        let currentTitledInputUserInfoView = TitledInputUserInfoView(title: "현재 \(editTargetItemType.title)", inputView: currentField)
        currentText = currentField.textObservable
        
        let targetField = InputFieldWithIcon(placeholder: "", unit: "kg")
        let targetTitledInputUserInfoView = TitledInputUserInfoView(title: "목표 \(editTargetItemType.title)", inputView: targetField)
        targetText = targetField.textObservable
        
        let fieldStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [currentTitledInputUserInfoView, targetTitledInputUserInfoView])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            return stackView
        }()
        
        mainStackView.addArrangedSubview(fieldStackView)
        
        let diffLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .systemGray
            label.textAlignment = .center
            label.layer.cornerRadius = 8
            return label
        }()
        diffLabel.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        mainStackView.addArrangedSubview(diffLabel)
        
        Observable.combineLatest(currentText, targetText) { current, target -> Double? in
            guard let currentValue = Double(current ?? ""), let targetValue = Double(target ?? "") else {
                return nil
            }
            return targetValue - currentValue
        }
        .subscribe(onNext: { [weak self] (diff: Double?) in
            guard let self = self else { return }
            
            if let diff = diff {
                diffLabel.text = String(format: "%.1f%@ %@", diff, self.editTargetItemType.unit, diff > 0 ? "증가" : "감소")
                diffLabel.textColor = diff > 0 ? .systemBlue : (diff < 0 ? .systemRed : .systemGray)
                diffLabel.backgroundColor = diff > 0 ? UIColor.systemBlue.withAlphaComponent(0.1) :
                (diff < 0 ? UIColor.systemRed.withAlphaComponent(0.1) : UIColor.clear)
            } else {
                diffLabel.text = "-"
                diffLabel.textColor = .systemGray
                diffLabel.backgroundColor = .clear
            }
        })
        .disposed(by: disposeBag)
        
        
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
}
