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
import Toast

final class SearchFoodViewController: UIViewController {
    private let viewModel: SearchFoodViewModel
    let selectedFoodDataRelay: BehaviorRelay<FoodData?> = BehaviorRelay(value: nil)
    
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
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()
    private let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
    
    var makeCreateFoodViewController: (() -> CreateFoodViewController?)?

    private let disposeBag = DisposeBag()
    private var presentationBag = DisposeBag()

    init(viewModel: SearchFoodViewModel) {
        self.viewModel = viewModel
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
        
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        toolbar.items = [flexSpace, doneButton]
        searchBar.searchTextField.inputAccessoryView = toolbar
        
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setBinding() {
        
        viewModel.toastMessageRelay
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message, duration: 1.5, position: .center)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                guard let self else { return }
                
                viewModel.searchQueryRelay.accept(query)
                
                if query.isEmpty {
                    viewModel.searchFoodResultRelay.accept([])
                    return
                }
                
                Task {
                    await self.viewModel.searchFood(foodName: query)
                }
            })
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                searchBar.searchTextField.resignFirstResponder()
            }
            .disposed(by: disposeBag)
        
        viewModel.searchFoodResultRelay
            .bind(to: tableView.rx.items(
                cellIdentifier: SearchResultFoodCell.identifier,
                cellType: SearchResultFoodCell.self
            )) { (_: Int, element: FoodData, cell: SearchResultFoodCell) in
                let brand = element.brand == "없음" ? "(제조사 정보 없음)" : element.brand
                cell.configure(
                    title: element.name,
                    brand: brand,
                    calory: String(element.perServingCalories),
                    carbon: String(element.carbohydrates),
                    protein: String(element.protein),
                    fat: String(element.fat),
                    info: "\(element.servingSize)\(element.unit) 기준"
                )
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(FoodData.self)
            .subscribe(onNext: { [weak self] foodData in
                guard let self else { return }
                
                selectedFoodDataRelay.accept(foodData)
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] offset in
                guard let self else { return }

                let offsetY = offset.y
                let contentHeight = self.tableView.contentSize.height
                let visibleHeight = self.tableView.frame.height - self.tableView.contentInset.bottom
                
                if offsetY > contentHeight - visibleHeight - 50,
                   !self.viewModel.isLastPage,
                   !self.viewModel.isLoadingNextPageRelay.value {

                    Task { [weak self] in
                        guard let self else { return }
                        await viewModel.fetchSearchFood(
                            foodName: viewModel.searchQueryRelay.value
                        )
                    }
                }
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
                guard let factory = makeCreateFoodViewController,
                      let createFoodViewController = factory() else { return }

                presentationBag = DisposeBag()
                createFoodViewController.createdFoodRelay
                    .compactMap { $0 }
                    .take(1)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] food in
                        guard let self else { return }
                        selectedFoodDataRelay.accept(food)
                        navigationController?.popViewController(animated: true)
                    })
                    .disposed(by: presentationBag)

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
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
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
        mainStackView.addArrangedSubview(brandLabel)
        
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
    
    func configure(title: String, brand: String, calory: String, carbon: String, protein: String, fat: String, info: String) {
        titleLabel.text = title
        brandLabel.text = brand
        kcalLabel.text = "\(calory)kcal"
        carbLabel.text = "탄 \(carbon)g"
        proteinLabel.text = "단 \(protein)g"
        fatLabel.text = "지 \(fat)g"
        infoLabel.text = info
    }
}

