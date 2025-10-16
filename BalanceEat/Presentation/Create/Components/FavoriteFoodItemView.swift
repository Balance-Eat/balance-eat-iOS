//
//  FavoriteFoodItemView.swift
//  BalanceEat
//
//  Created by 김견 on 7/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct FavoriteFood {
    let iconImage: UIImage
    let name: String
    let calorie: Int
}

final class FavoriteFoodItemView: UIView {
    private let favoriteFood: FavoriteFood
    private let index: Int
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .favoriteFoodName
        return label
    }()
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .favoriteFoodCalorie
        return label
    }()
    
    private let disposeBag = DisposeBag()
    private let tap: PublishSubject<Int> = .init()
    var tapObservable: Observable<Int> {
        tap.asObservable()
    }
    
    init(favoriteFood: FavoriteFood, index: Int) {
        self.favoriteFood = favoriteFood
        self.index = index
        super.init(frame: .zero)
        
        setUpView()
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.alpha = 0.6
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.alpha = 1.0
    }
    
    private func setUpView() {
        iconImageView.image = favoriteFood.iconImage
        nameLabel.text = favoriteFood.name
        calorieLabel.text = "\(favoriteFood.calorie) kcal"
        
        [iconImageView, nameLabel, calorieLabel].forEach {
            addSubview($0)
        }
        
        self.backgroundColor = .favoriteFoodBackground
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.mealTimePickerBorder.cgColor
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        calorieLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setUpBinding() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.tap.onNext(self.index)
            }
            .disposed(by: disposeBag)
    }
}
