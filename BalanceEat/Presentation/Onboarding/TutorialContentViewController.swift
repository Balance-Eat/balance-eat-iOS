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

class TutorialContentViewController: UIViewController, UIPageViewControllerDelegate {
    private let pageTitle: [String] = [
        "기본 정보 입력",
        "목표 설정",
        "활동량 선택"
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var tutorialIndicatorView = TutorialPageIndicatorView(currentPage: 1, totalPage: pageTitle.count)
    private let tutorialPageViewController = TutorialPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let disposeBag = DisposeBag()
        
    init() {
        super.init(nibName: nil, bundle: nil)
        setUpView()
        addTutorialPageViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(tutorialIndicatorView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(containerView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(16)
        }
        
        tutorialIndicatorView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(tutorialIndicatorView.snp.bottom).offset(50)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView)
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
        
        addChild(tutorialPageViewController)
        containerView.addSubview(tutorialPageViewController.view)
        
        tutorialPageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.greaterThanOrEqualTo(100)
        }
        
        tutorialPageViewController.didMove(toParent: self)
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
