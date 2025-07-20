//
//  CreateViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CreateViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let disposeBag = DisposeBag()
    private var mealTime: MealTime = .breakfast
    
    private lazy var mealTimePickerView: MealTimePickerView = {
        let view = MealTimePickerView(selectedMealTime: mealTime)
        view.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        return view
    }()
    private lazy var mealTimeTitledView = TitledContainerView(title: "언제 드셨나요?", contentView: mealTimePickerView)
    private let searchInputField = SearchInputField(placeholder: "음식 이름을 입력하세요")
    private lazy var searchMealTitledView = TitledContainerView(title: "음식 검색", contentView: searchInputField)
    
    private let favoriteFoodItemView = FavoriteFoodItemView(iconImage: .chickenChest, name: "닭가슴살", calorie: 165)
    
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mealTimeTitledView)
        contentView.addSubview(searchMealTitledView)
        contentView.addSubview(favoriteFoodItemView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        mealTimeTitledView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        searchMealTitledView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mealTimeTitledView)
            make.top.equalTo(mealTimeTitledView.snp.bottom).offset(20)
//            make.bottom.equalToSuperview().inset(20)
        }
        
        favoriteFoodItemView.snp.makeConstraints { make in
            make.top.equalTo(searchMealTitledView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
            make.width.equalTo(300)
        }
    }
    
    private func setBinding() {
        searchInputField.textObservable
            .compactMap { $0 }
            .distinctUntilChanged()
            .bind { text in
                print("📝 입력된 텍스트: \(text)")
                
            }
            .disposed(by: disposeBag)
        
        searchInputField.searchTap
            .bind {
                print("🔍 돋보기 아이콘 눌림!")
                
            }
            .disposed(by: disposeBag)
    }
}
