//
//  LoginViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/10/25.
//

import UIKit
import SnapKit
import RxSwift

class LoginViewController: UIViewController {
    private let oAuthSignInButton: OAuthSignInButton = {
        let oAuthSignInButton = OAuthSignInButton(icon: UIImage(systemName: "pencil.slash")!, name: "name", color: UIColor.red, textColor: UIColor.blue)
        return oAuthSignInButton
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        view.addSubview(oAuthSignInButton)
        oAuthSignInButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
