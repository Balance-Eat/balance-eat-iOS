//
//  TutorialPageViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TutorialPageViewController: UIViewController {
    let currentPageRelay = PublishRelay<(currentIndex: Int, totalPages: Int)>()
    
    private var pages: [UIViewController] = []
    private(set) var currentIndex: Int = 0
    private var previousIndex: Int = 0
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPage()
        displayCurrentPage(animated: true)
    }
    
    private func setUpPage() {
        let basicInfoViewController = BasicInfoViewController()
        
        basicInfoViewController.inputCompleted
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.goToNextPage()
            })
            .disposed(by: disposeBag)
        
        let targetInfoViewController = TargetInfoViewController()
        
        targetInfoViewController.inputCompleted
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.goToNextPage()
            })
            .disposed(by: disposeBag)
        
        let activityLevelViewController = ActivityLevelViewController()
        
        activityLevelViewController.inputCompleted
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.goToNextPage()
            })
            .disposed(by: disposeBag)
        
        pages.append(basicInfoViewController)
        pages.append(targetInfoViewController)
        pages.append(activityLevelViewController)
    }
    
    private func displayCurrentPage(animated: Bool) {
        if let currentChild = children.first {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        
        let vc = pages[currentIndex]
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        currentPageRelay.accept((currentIndex: currentIndex, totalPages: pages.count))
        previousIndex = currentIndex
    }
    
    func goToNextPage() {
        guard currentIndex + 1 < pages.count else { return }
        previousIndex = currentIndex
        currentIndex += 1
        displayCurrentPage(animated: true)
    }
    
    func goToPreviousPage() {
        guard currentIndex - 1 >= 0 else { return }
        previousIndex = currentIndex
        currentIndex -= 1
        displayCurrentPage(animated: true)
    }
}
