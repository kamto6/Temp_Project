//
//  QUNewsHotTopicListCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation
import UIKit

class QUNewsHotTopicListCell: UITableViewCell {
    
    // MARK: - Properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 15)
        label.textColor = Quote_Gray1
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        
    }
    
    // MARK: - Publics
    
    func updatUI(with model: QUNewsListModel) {
        titleLabel.text = model.title
    }
}

extension QUNewsHotTopicListCell {
    
    // MARK: - Privates
    
    private func setupUI() {
        contentView.backgroundColor = Quote_White
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.right.equalToSuperview().offset(-bnScaleFit(12))
            make.top.equalToSuperview().offset(bnScaleFit(8))
        }
    }
    
}
