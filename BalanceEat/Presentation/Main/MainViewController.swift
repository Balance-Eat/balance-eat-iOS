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

enum SelectedTab: Int {
    case home = 0
    case create = 1
    case record = 2
    case statistics = 3
    case mypage = 4
}

struct TabItem {
    let iconImage: UIImage
    let title: String
    var isSelected: BehaviorRelay<Bool> = BehaviorRelay(value: false)
}

class MainViewController: UIViewController {
    private var selectedTab: SelectedTab = .home {
        didSet {
            for i in 0..<tabItems.count {
                if i == Int(selectedTab.rawValue) {
                    tabItems[i].isSelected.accept(true)
                } else {
                    tabItems[i].isSelected.accept(false)
                }
            }
            
        }
    }
    
    private var tabItems: [TabItem] = [
        TabItem(iconImage: UIImage(systemName: "house.fill") ?? UIImage(), title: "홈"),
        TabItem(iconImage: UIImage(systemName: "fork.knife") ?? UIImage(), title: "추가"),
        TabItem(iconImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill") ?? UIImage(), title: "식단 내역"),
        TabItem(iconImage: UIImage(systemName: "chart.line.text.clipboard.fill") ?? UIImage(), title: "통계"),
        TabItem(iconImage: UIImage(systemName: "line.horizontal.3") ?? UIImage(), title: "메뉴")
    ]
    private var tabButtons: [BottomNavigationBarTabButton] = []
    private let bottomNavigationBar: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    private let bottomNavigationBarTabButton: BottomNavigationBarTabButton = {
        let bottomNavigationBarTabButton = BottomNavigationBarTabButton(iconImage: UIImage(named: "GoogleLogo") ?? UIImage(), title: "구글")
        return bottomNavigationBarTabButton
    }()
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        view.addSubview(bottomNavigationBar)
        
        for (index, tabItem) in tabItems.enumerated() {
            let tabButton = BottomNavigationBarTabButton(iconImage: tabItem.iconImage, title: tabItem.title)
            
            // 버튼 isSelected와 tabItem isSelected 바인딩
            tabButton.bindSelected(tabItem.isSelected.asObservable())
            
            // 버튼 탭 이벤트 구독
            tabButton.tapObservable
                .subscribe(onNext: { [weak self] in
                    self?.selectedTab = SelectedTab(rawValue: index) ?? .home
                })
                .disposed(by: disposeBag)
            
            bottomNavigationBar.addArrangedSubview(tabButton)
            tabButtons.append(tabButton)
        }
        
        bottomNavigationBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
