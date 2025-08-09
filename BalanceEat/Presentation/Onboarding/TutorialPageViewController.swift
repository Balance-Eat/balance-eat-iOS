//
//  TutorialPageViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/9/25.
//

import UIKit
import SnapKit

class TutorialPageViewController: UIPageViewController {
    private var pages: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPage()
        setUpUI()
    }
    
    private func setUpPage() {
        
    }
    
    private func setUpUI() {
        self.dataSource = self
        
        self.setViewControllers([pages[0]], direction: .forward, animated: true)
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
