//
//  ListViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DietListViewController: UIViewController {
    
    private let headerView = DietListHeaderView()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUpView() {
        view.backgroundColor = .homeScreenBackground
        
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        
    }
}

final class DietListHeaderView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.text = "식단 내역"
        return label
    }()
    
    private let openCalendarButton = OpenCalendarButton()
    
    private let previousDateButton: CountingButton = {
        let button = CountingButton(image: UIImage(systemName: "chevron.left"))
        return button
    }()
    
    private let nextDateButton: CountingButton = {
        let button = CountingButton(image: UIImage(systemName: "chevron.right"))
        return button
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let selectedDate = BehaviorRelay<Date>(value: Date())
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
        self.backgroundColor = .white
        if let formattedDate = formatKoreanDate("2025-09-29") {
            dateLabel.text = formattedDate
        }
        
        let mainStackview: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 16
            return stackView
        }()
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, openCalendarButton])
        titleStackView.axis = .horizontal
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .center
        
        let dateStackView = UIStackView(arrangedSubviews: [previousDateButton, dateLabel, nextDateButton])
        dateStackView.axis = .horizontal
        dateStackView.distribution = .equalSpacing
        dateStackView.alignment = .center
        
        [titleStackView, dateStackView, datePicker].forEach { mainStackview.addArrangedSubview($0) }
       
        addSubview(mainStackview)
        
        mainStackview.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        previousDateButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        nextDateButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
    }
    
    private func setBinding() {
        openCalendarButton.isSelectedRelay
            .map { !$0 }
            .bind(to: datePicker.rx.isHidden)
            .disposed(by: disposeBag)
        
        datePicker.rx.date
            .bind(to: selectedDate)
            .disposed(by: disposeBag)
        
        previousDateButton.tap
            .withLatestFrom(selectedDate)
            .map { Calendar.current.date(byAdding: .day, value: -1, to: $0) ?? $0 }
            .bind(to: selectedDate)
            .disposed(by: disposeBag)

        nextDateButton.tap
            .withLatestFrom(selectedDate)
            .map { Calendar.current.date(byAdding: .day, value: 1, to: $0) ?? $0 }
            .bind(to: selectedDate)
            .disposed(by: disposeBag)
        
        selectedDate
            .compactMap { [weak self] date -> String? in
                guard let self else { return nil }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatKoreanDate(formatter.string(from: date))
            }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        selectedDate
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                datePicker.setDate(date, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func formatKoreanDate(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let date = inputFormatter.date(from: dateString) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        return outputFormatter.string(from: date)
    }
}

final class OpenCalendarButton: UIButton {
    let isSelectedRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        setUpView()
        setBinding()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setUpView() {
        var config = UIButton.Configuration.plain()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = UIImage(systemName: "calendar", withConfiguration: symbolConfig)
        
        config.image = image
        config.baseBackgroundColor = .lightGray.withAlphaComponent(0.15)
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        self.configuration = config
        self.layer.cornerRadius = 8
    }
    
    private func setBinding() {
        isSelectedRelay
            .subscribe(onNext: { [weak self] isSelected in
                guard let self else { return }
                
                var updatedConfig = self.configuration
                updatedConfig?.baseForegroundColor = isSelected ? .white : .black
                
                UIView.animate(withDuration: 0.3) {
                    self.configuration = updatedConfig
                    self.backgroundColor = isSelected ? .systemBlue : .lightGray.withAlphaComponent(0.15)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func didTap() {
        isSelectedRelay.accept(!isSelectedRelay.value)
    }
}
