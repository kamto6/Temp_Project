//
//  QUHomeFollowEmptyView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/18.
//

import Foundation
import UIKit

class QUHomeFollowEmptyView: UIView {
    
    // MARK: - Properties
    
    var tapActionBlock: (() -> Void)?
    
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        label.textColor = Quote_Gray3
        label.text = NSLocalizedString("无心仪股票？去看看精选公司吧", comment: "")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        let tap = UITapGestureRecognizer { [weak self] _ in
            guard let self = self else { return }
            self.tapActionBlock?()
        }
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension QUHomeFollowEmptyView {
    
    // MARK: - Private
    
    private func setupUI() {
        backgroundColor = UIColor.color(colorHexString: "#F5F6FB")
        addSubview(plusSymolView)
        plusSymolView.addSubview(plusSymolIcon)
        addSubview(titleLabel)
        
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
