//
//  GoalSummaryContentView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class GoalSummaryContentView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let differenceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        return label
    }()
    private let differenceContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let disposeBag = DisposeBag()

    init(editTargetItemType: EditTargetItemType, currentRelay: BehaviorRelay<Double?>, targetRelay: BehaviorRelay<Double?>) {
        super.init(frame: .zero)

        self.backgroundColor = .white
        self.layer.cornerRadius = 8

        iconImageView.image = UIImage(systemName: editTargetItemType.systemImage)
        iconImageView.tintColor = editTargetItemType.color
        titleLabel.text = editTargetItemType.title

        Observable.combineLatest(currentRelay, targetRelay)
            .subscribe(onNext: { [weak self] current, target in
                guard let self else { return }
                guard let current else { return }
                guard let target else { return }

                let diff = target - current

                self.changeLabel.text = "\(current.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", current) : String(current))\(editTargetItemType.unit) → \(target.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", target) : String(target))\(editTargetItemType.unit)"

                if diff > 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 증가", diff, editTargetItemType.unit)
                    self.differenceLabel.textColor = .systemBlue
                    self.differenceContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                } else if diff < 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 감소", abs(diff), editTargetItemType.unit)
                    self.differenceLabel.textColor = .systemRed
                    self.differenceContainerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                } else {
                    self.differenceLabel.text = "변화 없음"
                    self.differenceLabel.textColor = .systemGray
                    self.differenceContainerView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
                }
            })
            .disposed(by: disposeBag)

        differenceContainerView.addSubview(differenceLabel)

        [iconImageView, titleLabel, changeLabel, differenceContainerView].forEach { addSubview($0) }

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        changeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(differenceLabel.snp.leading).offset(-16)
            make.centerY.equalToSuperview()
        }

        differenceLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }

        differenceContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
