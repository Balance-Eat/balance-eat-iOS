//
//  RemindNotificationCell.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift

final class RemindNotificationCell: UITableViewCell {
    let remindView = RemindNotificationView()
    var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(remindView)

        remindView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
