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
    
    private let vvvv: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    private lazy var titledContainerView = TitledContainerView(title: "타이트르를", contentView: vvvv)
    
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
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(300)
        }
    }
}
