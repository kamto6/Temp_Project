//
//  QUHomeFollowNoNetWorkView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/28.
//

import Foundation
import UIKit

class QUHomeFollowNoNetWorkView: UIView {
    
    // MARK: - Properties
    
    var tapActionBlock: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 14)
        label.textColor = Quote_Gray3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateLabel()
        let tap = UITapGestureRecognizer { [weak self] _ in
            guard let self = self else { return }
            self.tapActionBlock?()
        }
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLabel() {
        let attriText = NSMutableAttributedString(string: NSLocalizedString("加载失败", comment: ""), attributes: [.foregroundColor: Quote_Gray3, .font: UIFont.bnFont(fontStyle: .Regular, fontSize: 14)])
        attriText.append(NSMutableAttributedString(string: " ", attributes: [.font: UIFont.bnFont(fontStyle: .Regular, fontSize: 14)]))
        attriText.append(NSMutableAttributedString(string: NSLocalizedString("刷新", comment: ""), attributes: [.foregroundColor: Quote_THEME_COLOR, .font: UIFont.bnFont(fontStyle: .Regular, fontSize: 14)]))
        titleLabel.attributedText = attriText
    }
    
}

extension QUHomeFollowNoNetWorkView {
    
    // MARK: - Private
    
    private func setupUI() {
        backgroundColor = UIColor.color(colorHexString: "#F5F6FB")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
