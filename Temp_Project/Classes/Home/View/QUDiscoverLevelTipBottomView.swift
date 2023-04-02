//
//  QUDiscoverLevelTipBottomView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/24.
//

import Foundation
import UIKit

class QUDiscoverLevelTipBottomView: UIView {
    
    // MARK: - Properties
    
    private let textColor: UIColor = Quote_Gray3
    private let textFont: UIFont = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
    private let topMargin: CGFloat = bnScaleFit(8)
    private let leftMargin: CGFloat = bnScaleFit(20)
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = textFont
        label.textColor = textColor
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private var exchange: ExchangeType?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addNotifications()
        updateContent()
        let tap = UITapGestureRecognizer { [weak self] _ in
            guard let self = self else { return }
            if let exchange = self.exchange {
                BNQuoteJumpHelper.jumpQuotationSituation(exchange: exchange)
            }
        }
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        
    }
    
    // MARK: - Publics
    
    func updateContent() {
        guard let module = ServiceManager.sharedInstance.moduleByService(service: UserOpenService.self) as? UserOpenService else {
            return
        }
        let model = module.getPaperWorkModel(placeType: .discoverBottom, exchange: ExchangeType.unKnow.rawValue)
        contentLabel.text = model.title
    }
}

extension QUDiscoverLevelTipBottomView {
    
    // MARK: - Notifications
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnect), name: NSNotification.Name(rawValue: nkUpdateUserMarketAuthLevel), object: nil)
    }
    
    @objc private func socketConnect() {
        updateContent()
    }
    
    // MARK: - Privates
    
    private func setupUI() {
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.top.equalToSuperview().offset(topMargin)
            make.bottom.equalToSuperview().offset(-topMargin)
        }
    }
    
}
