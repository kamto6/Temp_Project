//
//  QUFlashMarqueeItem.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation
import UIKit

class QUFlashMarqueeItem: UIView {
    
    // MARK: - Properties

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        
    }
    
    // MARK: - Publics
    
    func updateUI(model: QUNewsListModel) {
        let attriText = NSMutableAttributedString()
        if let time = model.publicTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormat.basicFourth.rawValue
            let date = dateFormatter.date(from: time) as Date?
            let time = date?.toString(DateFormat.normal) ?? ""
            attriText.appendString(time)
            attriText.appendString(" ")
            attriText.addAttributes([.foregroundColor: Quote_THEME_COLOR, .font: UIFont.bnFont(fontStyle: .Regular, fontSize: 14)], range: NSRange(location: 0, length: time.length))
        }
        
        if let title = model.title {
            attriText.appendString(title)
            attriText.addAttributes([.foregroundColor: Quote_Gray1, .font: UIFont.bnFont(fontStyle: .Regular, fontSize: 14)], range: NSRange(location: attriText.length - title.length, length:title.length))
        }
        contentLabel.attributedText = attriText
        
    }
}

extension QUFlashMarqueeItem {
    
    // MARK: - Privates
    
    private func setupUI() {
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
}
