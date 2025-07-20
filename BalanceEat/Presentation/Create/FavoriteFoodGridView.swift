//
//  FavoriteFoodGridView.swift
//  BalanceEat
//
//  Created by 김견 on 7/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FavoriteFoodGridView: UIView {
    private let favoriteFoods: [FavoriteFood]
    
    private let disposeBag = DisposeBag()
    
    private let tappedIndexSubject = PublishSubject<Int>()
    var tappedIndexObservable: Observable<Int> {
        tappedIndexSubject.asObservable()
    }
    
    init(favoriteFoods: [FavoriteFood]) {
        self.favoriteFoods = favoriteFoods
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 8
        containerStackView.alignment = .fill
        containerStackView.distribution = .fillEqually
        self.addSubview(containerStackView)
        
        let titleLabel = UILabel()
        titleLabel.text = "좋아하는 음식"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .favoriteFoodName
        
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        var index = 0
        while index < favoriteFoods.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually
            
            for i in 0..<2 {
                if index + i < favoriteFoods.count {
                    let favoriteFoodItemView = FavoriteFoodItemView(favoriteFood: favoriteFoods[index + i], index: index + i)
                    
                    favoriteFoodItemView.tapObservable
                        .bind(to: tappedIndexSubject)
                        .disposed(by: disposeBag)
                    
                    rowStack.addArrangedSubview(favoriteFoodItemView)
                } else {
                    let emptyView = UIView()
                    rowStack.addArrangedSubview(emptyView)
                }
            }
            
            containerStackView.addArrangedSubview(rowStack)
            index += 2
        }
    }
}
