//
//  MainViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum SelectedTab: Int, CaseIterable {
    case home = 0, create, record, statistics, mypage
}

struct TabItem {
    let iconImage: UIImage
    let title: String
    var isSelected: BehaviorRelay<Bool> = BehaviorRelay(value: false)
}

class MainViewController: UIViewController {
    private var selectedTab: SelectedTab = .home {
        didSet {
            updateTabsAndViews()
        }
    }

    private let tabItems: [TabItem] = [
        TabItem(iconImage: UIImage(systemName: "house.fill") ?? UIImage(), title: "홈"),
        TabItem(iconImage: UIImage(systemName: "fork.knife") ?? UIImage(), title: "추가"),
        TabItem(iconImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill") ?? UIImage(), title: "식단 내역"),
        TabItem(iconImage: UIImage(systemName: "chart.line.text.clipboard.fill") ?? UIImage(), title: "통계"),
        TabItem(iconImage: UIImage(systemName: "line.horizontal.3") ?? UIImage(), title: "메뉴")
    ]

    private var tabButtons: [BottomNavigationBarTabButton] = []
    
    private let bottomNavigationBar = UIStackView()
    private let contentView = UIView()

    private let disposeBag = DisposeBag()

    private let viewControllers: [UIViewController] = [
        HomeViewController(),
        CreateViewController(),
        ListViewController(),
        ChartViewController(),
        MenuViewController()
    ]

    init() {
        super.init(nibName: nil, bundle: nil)
        setupUI()
        setupTabButtons()
        setupViewControllers()
        updateTabsAndViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = .white

        bottomNavigationBar.axis = .horizontal
        bottomNavigationBar.distribution = .fillEqually

        view.addSubview(bottomNavigationBar)
        view.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomNavigationBar.snp.top)
        }

        bottomNavigationBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
    }

    private func setupTabButtons() {
        for (index, tabItem) in tabItems.enumerated() {
            let tabButton = BottomNavigationBarTabButton(iconImage: tabItem.iconImage, title: tabItem.title)
            tabButton.bindSelected(tabItem.isSelected.asObservable())
            tabButton.tapObservable
                .subscribe(onNext: { [weak self] in
                    self?.selectedTab = SelectedTab(rawValue: index) ?? .home
                })
                .disposed(by: disposeBag)

            bottomNavigationBar.addArrangedSubview(tabButton)
            tabButtons.append(tabButton)
        }
    }

    private func setupViewControllers() {
        for vc in viewControllers {
            addChild(vc)
            contentView.addSubview(vc.view)
            vc.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            vc.didMove(toParent: self)
            vc.view.isHidden = true
        }
    }

    private func updateTabsAndViews() {
        for i in 0..<tabItems.count {
            tabItems[i].isSelected.accept(i == selectedTab.rawValue)
            viewControllers[i].view.isHidden = i != selectedTab.rawValue
        }
    }
}
