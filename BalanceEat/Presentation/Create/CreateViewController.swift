//
//  CreateViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit

class CreateViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var mealTime: MealTime = .breakfast
    
    private lazy var mealTimePickerView: MealTimePickerView = {
        let view = MealTimePickerView(selectedMealTime: mealTime)
        view.snp.makeConstraints { make in
            make.height.equalTo(40)  // 아이템 높이와 맞추기
        }
        return view
    }()
    private lazy var titledContainerView = TitledContainerView(title: "언제 드셨나요?", contentView: mealTimePickerView)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUpView() {
        view.backgroundColor = .homeScreenBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titledContainerView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        titledContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
    }
}
