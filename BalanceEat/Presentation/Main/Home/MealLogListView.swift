//
//  MealLogListView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MealLogListView: UIView {

    private let goToDietButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "식단 상세보기"
        config.titleAlignment = .leading
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var attr = attr
            attr.font = .systemFont(ofSize: 17, weight: .bold)
            attr.foregroundColor = .black
            return attr
        }
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        config.image = UIImage(systemName: "chevron.right", withConfiguration: imageConfig)
        config.imagePlacement = .trailing
        config.imagePadding = 8

        let button = UIButton(configuration: config)
        button.tintColor = .black
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()

    private let dietEmptyInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "오늘의 식단 기록이 없습니다"
        return label
    }()

    private let addDietButton = TitledButton(
        title: "식단 추가하기",
        image: UIImage(systemName: "plus"),
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemBlue, .systemBlue.withAlphaComponent(0.2)]
        )
    )

    private lazy var dietEmptyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dietEmptyInfoLabel, addDietButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    let mealLogsRelay = BehaviorRelay<[MealLogView]>(value: [])
    let goToDietButtonTapRelay = PublishRelay<Void>()
    let addDietButtonTapRelay = PublishRelay<Void>()
    private let logIsEmptyRelay = BehaviorRelay<Bool>(value: false)
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
        backgroundColor = .clear

        [goToDietButton, stackView, dietEmptyStackView].forEach(addSubview)

        goToDietButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(goToDietButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }

        dietEmptyStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }


    private func setBinding() {
        mealLogsRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] logs in
                self?.configureStackView(with: logs)
            })
            .disposed(by: disposeBag)

        mealLogsRelay
            .map { $0.isEmpty }
            .bind(to: logIsEmptyRelay)
            .disposed(by: disposeBag)

        logIsEmptyRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmpty in
                self?.toggleEmptyState(isEmpty: isEmpty)
            })
            .disposed(by: disposeBag)

        goToDietButton.rx.tap
            .bind(to: goToDietButtonTapRelay)
            .disposed(by: disposeBag)

        addDietButton.rx.tap
            .bind(to: addDietButtonTapRelay)
            .disposed(by: disposeBag)
    }

    private func configureStackView(with mealLogs: [MealLogView]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            mealLogs.forEach { log in

                stackView.addArrangedSubview(log)
            }
    }

    private func toggleEmptyState(isEmpty: Bool) {
        goToDietButton.isHidden = isEmpty
        stackView.isHidden = isEmpty
        dietEmptyStackView.isHidden = !isEmpty

        if isEmpty {
            dietEmptyStackView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview().inset(24)
            }
        } else {
            dietEmptyStackView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
}
