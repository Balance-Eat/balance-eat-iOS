//
//  ChartViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit

class ChartViewController: BaseViewController<ChartViewModel> {
    init() {
        let vm = ChartViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setBinding()
    }
    
    private func setUpView() {
        
    }
    
    private func setBinding() {
        
    }
}
