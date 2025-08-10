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
    private var currentIndex: Int = 0
    
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
        
        pages.append(basicInfoViewController)
        pages.append(LoginViewController())
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
        
        currentPageRelay.accept((currentIndex: currentIndex, totalPages: pages.count))
        
        if animated {
            vc.view.alpha = 0
            UIView.animate(withDuration: 0.3) {
                vc.view.alpha = 1
            }
        }
    }
    
    func goToNextPage() {
        guard currentIndex + 1 < pages.count else { return }
        currentIndex += 1
        displayCurrentPage(animated: true)
    }
    
    func goToPreviousPage() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        displayCurrentPage(animated: true)
    }
}
