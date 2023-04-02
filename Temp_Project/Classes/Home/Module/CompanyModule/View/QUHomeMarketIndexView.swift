//
//  QUHomeMarketIndexView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/15.
//

import Foundation
import UIKit
import BNPAPI

protocol QUHomeMarketIndexViewDelegate: NSObjectProtocol {
    
    func didSelectIndex(view: QUHomeMarketIndexView, with indexType: QUMarketIndexType, exchange: ExchangeType)
}

class QUHomeMarketIndexView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: QUHomeMarketIndexViewDelegate?
    
    /// 公司logo
    private lazy var exchangeLogo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: getExchangeTypeIcon(with: exchange))
        return view
    }()
    
    /// 市场类型
    private lazy var exchangeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 14)
        label.textColor = Quote_Gray2
        label.text = getExchangeTypeTitle(with: exchange)
        return label
    }()
    
    /// 交易状态类型
    private lazy var tradeStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        label.textColor = Quote_Gray3
        return label
    }()
    

    private var exchange: ExchangeType!
    
    /// 切换类别
    private var indexTypeList: [QUMarketIndexType] = []
    
    private lazy var leftIndexView: QUHomeMarketIndexItemView = {
        let view = QUHomeMarketIndexItemView(frame: CGRect.zero, indexType: getIndexType(with: 0))
        view.delegate = self
        return view
    }()
    
    private lazy var middleIndexView: QUHomeMarketIndexItemView = {
        let view = QUHomeMarketIndexItemView(frame: CGRect.zero, indexType: getIndexType(with: 1))
        view.delegate = self
        return view
    }()
    
    private lazy var rightIndexView: QUHomeMarketIndexItemView = {
        let view = QUHomeMarketIndexItemView(frame: CGRect.zero, indexType: getIndexType(with: 2))
        view.delegate = self
        return view
    }()
    
    private lazy var indexViews: [QUHomeMarketIndexItemView] = {
        return [leftIndexView, middleIndexView, rightIndexView]
    }()
    
    // MARK: - Init
    
    init(frame: CGRect, exchange: ExchangeType, indexTypeList: [QUMarketIndexType]) {
        super.init(frame: frame)
        self.exchange = exchange
        self.indexTypeList = indexTypeList
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        
    }
    
    // MARK: - Publics
    func updateUI(with indexType: QUMarketIndexType, msg: QuoteBasicPrice) {
        if let indexView = indexViews.filter({ $0.indexType == indexType }).first {
            indexView.updateData(msg: msg)
        }
        var trade = ""
        if exchange == .US, msg.hasPreAfterPrice, let tradeStatus = QUTradeStatusType(rawValue: Int(msg.preAfterPrice.tradeStatus)) {
            trade = tradeStatus.title
        } else {
            if let tradeStatus = QUTradeStatusType(rawValue: Int(msg.tradeStatus)) {
                trade = tradeStatus.title
            }
        }
        tradeStatusLabel.text = String(format: "%@ %@", trade, String.timeWithExchangeToTimeString(timeInterval: TimeInterval(msg.sourceTime), isMilliSecond: true, "MM-dd", exchange: exchange))
    }
    
    func colorChanged() {
        for item in indexViews {
            item.updateLabelColor()
        }
    }
}

extension QUHomeMarketIndexView {
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates

    private func getIndexType(with index: Int) -> QUMarketIndexType {
        var indexType: QUMarketIndexType = .HSI
        if index < indexTypeList.count {
            indexType = indexTypeList[index]
        }
        return indexType
    }
    
    private func setupUI() {
        backgroundColor = Quote_White
        addSubview(exchangeLogo)
        addSubview(exchangeLabel)
        addSubview(tradeStatusLabel)
        addSubview(leftIndexView)
        addSubview(middleIndexView)
        addSubview(rightIndexView)
        
        exchangeLogo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(20))
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: bnScaleFit(20), height: bnScaleFit(20)))
        }
        exchangeLabel.snp.makeConstraints { make in
            make.left.equalTo(exchangeLogo.snp.right).offset(bnScaleFit(6))
            make.centerY.equalTo(exchangeLogo)
        }
        tradeStatusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(20))
            make.centerY.equalTo(exchangeLogo)
        }
        let itemWidth = (kScreenW - bnScaleFit(40) - bnScaleFit(24)) / CGFloat(3)
        leftIndexView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(20))
            make.top.equalTo(exchangeLogo.snp.bottom).offset(bnScaleFit(8))
            make.width.equalTo(itemWidth)
            make.height.equalTo(bnScaleFit(78))
        }
        middleIndexView.snp.makeConstraints { make in
            make.left.equalTo(leftIndexView.snp.right).offset(bnScaleFit(12))
            make.centerY.equalTo(leftIndexView)
            make.width.equalTo(itemWidth)
            make.height.equalTo(bnScaleFit(78))
        }
        rightIndexView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(20))
            make.centerY.equalTo(leftIndexView)
            make.width.equalTo(itemWidth)
            make.height.equalTo(bnScaleFit(78))
        }
    }
    
    private func getExchangeTypeTitle(with exchange: ExchangeType) -> String {
        switch exchange {
        case .unKnow:
            bnAssertionFailure("精选公司市场未知类型")
            return ""
        case .HK:
            return NSLocalizedString("港股市场", comment: "")
        case .US:
            return NSLocalizedString("美股市场", comment: "")
        }
    }
    
    func getExchangeTypeIcon(with exchange: ExchangeType) -> String {
        switch exchange {
        case .unKnow:
            bnAssertionFailure("精选公司市场未知类型")
            return ""
        case .HK:
            return "static_quote_hk_exchange_logo"
        case .US:
            return "static_quote_us_exchange_logo"
        }
    }
    
}

extension QUHomeMarketIndexView: QUHomeMarketIndexItemViewDelegate {
    
    func didSelectIndex(view: QUHomeMarketIndexItemView, with indexType: QUMarketIndexType) {
        delegate?.didSelectIndex(view: self, with: indexType, exchange: exchange)
    }
}
