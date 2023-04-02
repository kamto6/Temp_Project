//
//  QUHomeMarketIndexItemView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/15.
//

import BNUMain
import UIKit

protocol QUHomeMarketIndexItemViewDelegate: NSObjectProtocol {
    
    func didSelectIndex(view: QUHomeMarketIndexItemView, with indexType: QUMarketIndexType)
}

class QUHomeMarketIndexItemView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: QUHomeMarketIndexItemViewDelegate?
    
    var indexType: QUMarketIndexType = .HSI {
        didSet {
            nameLabel.text = indexType.title
        }
    }
  
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Quote_Gray2
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Quote_Gray3
        label.font = UIFont.bnFont(fontStyle: .MunkenSansBold, fontSize: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.text = "--"
        return label
    }()
    
    private lazy var updownLabel: UILabel = {
        let label = UILabel()
        label.textColor = Quote_Gray3
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 12)
        label.textAlignment = .center
        label.text = "--"
        return label
    }()
    
    // MARK: - Override
    
    init(frame: CGRect, indexType: QUMarketIndexType) {
        super.init(frame: frame)
        setupUI()
        initData(indexType: indexType)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
    // MARK: - Publics
    
    func updateData(msg: QuoteBasicPrice) {
        let categoryType = CategoryType(rawValue: Int(msg.commonInfo.categoryType)) ?? .mainBoard
        let exchange = ExchangeType(rawValue: Int(msg.commonInfo.exchange)) ?? .HK
        
        priceLabel.text = MPMarketDataHelper.getStockPriceWithValue(value: Int(msg.last), categoryType: categoryType, exchange: exchange)
        priceLabel.textColor = Quote_Gray1

        let rfRatioStr = MPMarketDataHelper.getPercentStrWithValue(value: Double(msg.rFRatio), divisor: MPThousand, hasSymbol: true)
        updownLabel.text = rfRatioStr
        
        let updownColor = MPMarketDataHelper.getPriceTextColor(value: Double(msg.rFRatio), zeroColor: Quote_Flat_Color)
        updownLabel.textColor = updownColor
    }
    
    func updateLabelColor() {
        guard let updown = updownLabel.text else { return }
        let updownColor = MPMarketDataHelper.getPriceTextColor(valueStr: updown, zeroColor: Quote_Flat_Color)
        updownLabel.textColor = updownColor
    }
    
}

extension QUHomeMarketIndexItemView {
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func initData(indexType: QUMarketIndexType) {
        self.indexType = indexType
    }
    
    private func setupUI() {
        addSubview(nameLabel)
        addSubview(priceLabel)
        addSubview(updownLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(4))
            make.right.equalToSuperview().offset(bnScaleFit(-4))
            make.top.equalToSuperview().offset(bnScaleFit(7))
            make.height.equalTo(bnScaleFit(18))
        }
        priceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(4))
            make.right.equalToSuperview().offset(bnScaleFit(-4))
            make.top.equalTo(nameLabel.snp.bottom).offset(bnScaleFit(5))
            make.height.equalTo(bnScaleFit(20))
        }
        updownLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(4))
            make.right.equalToSuperview().offset(bnScaleFit(-4))
            make.top.equalTo(priceLabel.snp.bottom).offset(bnScaleFit(2))
        }
    }
    
    @objc private func tapAction(_ recognizer: UITapGestureRecognizer) {
        delegate?.didSelectIndex(view: self, with: indexType)
    }
   
}


