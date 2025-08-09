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

class TutorialPageViewController: UIPageViewController {
    let currentPageRelay = PublishRelay<(currentIndex: Int, totalPages: Int)>()
    
    private var pages: [UIViewController] = []
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPage()
        setUpUI()
    }
    
    private func setUpPage() {
        let basicInfoViewController = BasicInfoViewController()
        
        basicInfoViewController.inputCompleted
            .subscribe(onNext: { [weak self, weak basicInfoViewController] in
                guard let self = self, let currentViewController = basicInfoViewController else { return }
                self.goToNextPage(from: currentViewController)
            })
            .disposed(by: disposeBag)
        
        pages.append(basicInfoViewController)
    }
    
    private func setUpUI() {
        self.dataSource = self
        self.delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
            currentPageRelay.accept((currentIndex: 0, totalPages: pages.count))
        }
    }
    
    private func goToNextPage(from currentViewController: UIViewController) {
        guard let currentIndex = pages.firstIndex(of: currentViewController) else { return }
        let nextIndex = currentIndex + 1
        guard nextIndex < pages.count else { return }
        
        let nextViewController = pages[nextIndex]
        setViewControllers([nextViewController], direction: .forward, animated: true)
    }
}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        guard currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        guard currentIndex < (pages.count - 1) else { return nil }
        return pages[currentIndex + 1]
    }
}

extension TutorialPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else { return }
        
        currentPageRelay.accept((currentIndex: currentIndex, totalPages: pages.count))
    }
}
