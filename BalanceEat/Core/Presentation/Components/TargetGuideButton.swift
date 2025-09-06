//
//  TargetGuideButton.swift
//  BalanceEat
//
//  Created by 김견 on 9/6/25.
//


import UIKit
import RxSwift
import RxCocoa

final class TargetGuideButton: UIButton {

    var tapObservable: Observable<Void> {
        return self.rx.tap.asObservable()
    }

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }

    private func configureButton() {
        var config = UIButton.Configuration.plain()
        config.title = " 건강한 목표 설정 가이드 보기"
        config.image = UIImage(systemName: "info.circle")
        config.baseForegroundColor = .systemBlue
        config.imagePadding = 8
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        config.imagePlacement = .leading
        
        self.configuration = config
    }
}
