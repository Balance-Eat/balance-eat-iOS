//
//  SearchFoodViewController.swift
//  BalanceEat
//
//  Created by 김견 on 9/8/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SearchFoodViewController: UIViewController {
    private let viewModel: SearchFoodViewModel
    
    private let contentView = UIView()
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "음식 이름을 입력해주세요."
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultFoodCell.self, forCellReuseIdentifier: SearchResultFoodCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        return tableView
    }()
    
    private let noFoodLabel: UILabel = {
        let label = UILabel()
        label.text = "찾으시는 음식이 없어요.\n새 음식을 추가하세요."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let createFoodButton = TitledButton(
        title: "음식 직접 추가하기",
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemGreen, .systemGreen.withAlphaComponent(0.5)]
        )
    )
    
    private let searchHistory = BehaviorRelay<[FoodDTO]>(
        value: [
//            FoodDTO(
//                id: 1,
//                uuid: "213",
//                name: "바나나",
//                perCapitaIntake: 12,
//                unit: "g",
//                carbohydrates: 30,
//                protein: 40,
//                fat: 40,
//                createdAt: "2025-09-08T12:34:56Z"
//            ),
//            FoodDTO(
//                id: 2,
//                uuid: "1234",
//                name: "닭가슴살",
//                perCapitaIntake: 14,
//                unit: "g",
//                carbohydrates: 40,
//                protein: 40,
//                fat: 40,
//                createdAt: "2025-09-08T12:34:56Z"
//            )
        ]
    )
    private let disposeBag = DisposeBag()
    
    init() {
        let foodRepository = FoodRepository()
        let foodUseCase = FoodUseCase(repository: foodRepository)
        self.viewModel = SearchFoodViewModel(foodUseCase: foodUseCase)
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setUpView() {
        view.backgroundColor = .homeScreenBackground
        view.addSubview(contentView)
        contentView.addSubview(tableView)
        contentView.addSubview(createFoodButton)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let noFoodStackView = UIStackView(arrangedSubviews: [noFoodLabel, createFoodButton])
        noFoodStackView.axis = .vertical
        noFoodStackView.spacing = 8
        
        contentView.addSubview(noFoodStackView)
        
        noFoodStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setBinding() {
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                guard let self else { return }
                if query.isEmpty {
                    viewModel.searchFoodResultRelay.accept([])
                    return
                }
                
                Task {
                    await self.viewModel.searchFood(foodName: query, isNew: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.searchFoodResultRelay
            .bind(to: tableView.rx.items(cellIdentifier: SearchResultFoodCell.identifier)) { row, element, cell in
                let calory = Int(element.carbohydrates * 4 + element.protein * 4 + element.fat * 9)
                
                if let cell = cell as? SearchResultFoodCell {
                    cell.configure(
                        title: element.name,
                        calory: String(calory),
                        carbon: String(element.carbohydrates),
                        protein: String(element.protein),
                        fat: String(element.fat),
                        info: "\(element.perCapitaIntake)\(element.unit) 기준"
                    )
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(FoodDTOForSearch.self)
            .subscribe(onNext: { food in
                print("선택된 검색어: \(food.name)")
            })
            .disposed(by: disposeBag)
        
        viewModel.searchFoodResultRelay
            .map { $0.count > 0 }
            .bind(to: createFoodButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.searchFoodResultRelay
            .map { $0.count > 0 }
            .bind(to: noFoodLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        createFoodButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                let createFoodViewController = CreateFoodViewController()
                if let sheet = createFoodViewController.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
                present(createFoodViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
}

final class SearchResultFoodCell: UITableViewCell {
    static let identifier = "SearchResultFoodCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()
    
    private let kcalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemOrange
        return label
    }()
    
    private let carbLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .carbonText
        return label
    }()
    
    private let proteinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .proteinText
        return label
    }()
    
    private let fatLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .fatText
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        let plusImage = UIImage(systemName: "plus.circle")
        button.setImage(plusImage, for: .normal)
        button.tintColor = .systemBlue
        button.setPreferredSymbolConfiguration(.init(pointSize: 24, weight: .regular), forImageIn: .normal)
        return button
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpView()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        backgroundColor = .white
        
        
        
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(titleLabel)
        
        let hStackContainer = UIView()
        hStackContainer.addSubview(horizontalStackView)
        hStackContainer.addSubview(addButton)
        
        horizontalStackView.addArrangedSubview(kcalLabel)
        horizontalStackView.addArrangedSubview(carbLabel)
        horizontalStackView.addArrangedSubview(proteinLabel)
        horizontalStackView.addArrangedSubview(fatLabel)
        
        mainStackView.addArrangedSubview(hStackContainer)
        mainStackView.addArrangedSubview(infoLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(12)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        horizontalStackView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(horizontalStackView)
            make.trailing.equalToSuperview()
        }
    }
    
    func configure(title: String, calory: String, carbon: String, protein: String, fat: String, info: String) {
        titleLabel.text = title
        kcalLabel.text = "\(calory)kcal"
        carbLabel.text = "탄 \(carbon)g"
        proteinLabel.text = "단 \(protein)g"
        fatLabel.text = "지 \(fat)g"
        infoLabel.text = info
    }
}

