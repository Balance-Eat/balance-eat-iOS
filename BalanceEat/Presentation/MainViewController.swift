//
//  MainViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift

class MainViewController: UIViewController {
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "메인화면"
        textView.textColor = .label
        textView.font = .systemFont(ofSize: 30, weight: .bold)
        return textView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .green
        view.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
