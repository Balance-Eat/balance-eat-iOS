//
//  SearchResultFoodCell.swift
//  BalanceEat
//

import UIKit
import SnapKit

final class SearchResultFoodCell: UITableViewCell {
    static let identifier = "SearchResultFoodCell"

    private let containerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appNeutral.withAlphaComponent(0.3).cgColor
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
        label.textColor = .appWarning
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

        accessibilityLabel = "\(title), \(brand), \(calory)kcal, 탄수화물 \(carbon)g, 단백질 \(protein)g, 지방 \(fat)g, \(info)"
        isAccessibilityElement = true
    }
}
