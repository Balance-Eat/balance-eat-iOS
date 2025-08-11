//
//  TutorialContentViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TutorialContentViewController: UIViewController {
    private let pageTitle: [String] = [
        "기본 정보 입력",
        "목표 설정",
        "활동량 선택"
    ]
    
    private let backButton = BackButton()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var tutorialIndicatorView = TutorialPageIndicatorView(currentPage: 1, totalPage: pageTitle.count)
    private let tutorialPageViewController = TutorialPageViewController()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let disposeBag = DisposeBag()
        
    init() {
        super.init(nibName: nil, bundle: nil)
        setUpView()
        addTutorialPageViewController()
        bindBackButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setUpView() {
        let titleStackView = UIStackView(arrangedSubviews: [backButton, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 8
        
        contentView.addSubview(titleStackView)
        contentView.addSubview(tutorialIndicatorView)
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        tutorialIndicatorView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func addTutorialPageViewController() {
        tutorialPageViewController.currentPageRelay
            .map { $0.currentIndex + 1 }
            .bind(to: tutorialIndicatorView.currentPageRelay)
            .disposed(by: disposeBag)
        
        tutorialPageViewController.currentPageRelay
            .map { [weak self] pageInfo -> String in
                guard let self = self else { return "" }
                let index = pageInfo.currentIndex
                return index < self.pageTitle.count ? self.pageTitle[index] : ""
            }
            .observe(on: MainScheduler.instance)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        tutorialPageViewController.currentPageRelay
            .map { $0.currentIndex }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] currentIndex in
                guard let self = self else { return }
                self.backButton.isHidden = (currentIndex == 0)  
            })
            .disposed(by: disposeBag)
        
//        addChild(tutorialPageViewController)
        contentView.addSubview(tutorialPageViewController.view)
        
        tutorialPageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tutorialIndicatorView.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview()
//            make.height.greaterThanOrEqualTo(400)
            make.bottom.equalToSuperview()
        }
        
        tutorialPageViewController.didMove(toParent: self)
    }
    
    private func bindBackButton() {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.tutorialPageViewController.currentIndex > 0 {
                    self.tutorialPageViewController.goToPreviousPage()
                }
            })
            .disposed(by: disposeBag)
    }
}


final class TutorialPageIndicatorView: UIView {

    private var totalPage: Int = 0
    
    private let currentStepLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .darkGray
        
        return label
    }()
    
    private let pageStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .black
        
        return label
    }()
    
    private let backgroundBar = UIView()
    private let progressBar = UIView()
    
    let currentPageRelay = BehaviorRelay<Int>(value: 1)
    private let disposeBag = DisposeBag()
    
    init(currentPage: Int, totalPage: Int) {
        super.init(frame: .zero)
        currentPageRelay.accept(currentPage)
        self.totalPage = totalPage
        
        setUpView()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(currentStepLabel)
        addSubview(pageStateLabel)
        addSubview(backgroundBar)
        addSubview(progressBar)
        
        currentStepLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        pageStateLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }
        
        backgroundBar.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        backgroundBar.layer.cornerRadius = 5
        backgroundBar.snp.makeConstraints { make in
            make.leading.equalTo(currentStepLabel.snp.leading)
            make.trailing.equalTo(pageStateLabel.snp.trailing)
            make.top.equalTo(currentStepLabel.snp.bottom).offset(8)
            make.height.equalTo(10)
        }
        
        progressBar.backgroundColor = UIColor.systemBlue
        progressBar.layer.cornerRadius = 5
        backgroundBar.addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
    }
    
    private func bindUI() {
        currentPageRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] currentPage in
                guard let self = self else { return }
                self.updateLabels(currentPage: currentPage)
                self.updateProgressBar(currentPage: currentPage)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateProgressBar(currentPage: Int) {
        let progress = CGFloat(currentPage) / CGFloat(totalPage)
        let maxWidth = backgroundBar.bounds.width
        backgroundBar.layoutIfNeeded()
        
        let newWidth = maxWidth * progress
        
        progressBar.snp.updateConstraints { make in
            make.width.equalTo(newWidth)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundBar.layoutIfNeeded()
        }
    }
    
    private func updateLabels(currentPage: Int) {
        currentStepLabel.text = "\(currentPage)단계"
        pageStateLabel.text = "\(currentPage)/\(totalPage)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressBar(currentPage: currentPageRelay.value)
    }
}
