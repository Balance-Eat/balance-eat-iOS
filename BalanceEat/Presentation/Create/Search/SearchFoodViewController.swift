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

final class SearchFoodViewController: BaseViewController<SearchFoodViewModel> {
    let selectedFoodDataRelay: BehaviorRelay<FoodData?> = BehaviorRelay(value: nil)

    private let searchContentView = UIView()
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
    
    private let createFoodButton: TitledButton = {
        let button = TitledButton(
            title: "음식 직접 추가하기",
            style: .init(
                backgroundColor: nil,
                titleColor: .white,
                borderColor: nil,
                gradientColors: [.appPositive, .appPositive.withAlphaComponent(0.5)]
            )
        )
        button.accessibilityLabel = "음식 직접 추가하기"
        button.accessibilityHint = "데이터베이스에 없는 음식을 직접 등록합니다"
        return button
    }()
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()
    private let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
    
    var makeCreateFoodViewController: (() -> CreateFoodViewController?)?

    private var presentationBag = DisposeBag()

    override init(viewModel: SearchFoodViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setUpView() {
        topContentView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }

        view.addSubview(searchContentView)
        searchContentView.addSubview(tableView)
        searchContentView.addSubview(createFoodButton)

        searchContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let noFoodStackView = UIStackView(arrangedSubviews: [noFoodLabel, createFoodButton])
        noFoodStackView.axis = .vertical
        noFoodStackView.spacing = 8

        searchContentView.addSubview(noFoodStackView)

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

        view.bringSubviewToFront(loadingView)
    }
    
    private func setBinding() {
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
                // take(1): SearchFoodViewController는 push/pop 후 재사용된다.
                // 구독이 누적되면 음식 선택 콜백이 중복 호출되므로 첫 번째 이벤트만 수신한다.
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
    }
}

