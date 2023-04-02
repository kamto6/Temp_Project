//
//  QUHomeFollowFooterCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/18.
//

import Foundation
import UIKit

class QUHomeFollowFooterCell: UICollectionViewCell {
    
    // MARK: - Properties

    private lazy var plusSymolIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_icon_add_bold")
        return view
    }()
    
    private lazy var plusSymolView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = bnScaleFit(18)
        return view
    }()
    
    private lazy var titleLabel: UIView = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        label.textColor = Quote_Gray3
        label.text = NSLocalizedString("去添加", comment: "")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension QUHomeFollowFooterCell {
    
    // MARK: - Private
    
    private func setupUI() {
        contentView.backgroundColor = kMyWatchListBgColor
        contentView.layer.cornerRadius = bnScaleFit(8)
        
        contentView.addSubview(plusSymolView)
        plusSymolView.addSubview(plusSymolIcon)
        contentView.addSubview(titleLabel)
        
        plusSymolView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(22))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(bnScaleFit(36))
        }
        plusSymolIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(70))
            make.centerY.equalToSuperview()
        }
    }
    
}
