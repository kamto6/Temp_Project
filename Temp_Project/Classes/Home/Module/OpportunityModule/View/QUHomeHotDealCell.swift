//
//  QUHomeHotDealCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation
import UIKit

class QUHomeHotDealCell: UITableViewCell {
    
    // MARK: - Properties
    
    /// 排名
    private lazy var rankImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.bnFont(fontStyle: .Semibold, fontSize: 14)
        label.textColor = UIColor.color(colorHexString: "#878D9A")
        label.isHidden = true
        return label
    }()
    
    /// 股票名称
    private lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        label.textColor = Quote_Gray1
        return label
    }()
    
    /// 市场icon
    private lazy var exchangeIcon: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    /// 股票代码
    private lazy var stockCodeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        label.textColor = Quote_Gray2
        return label
    }()
    
    /// 最新价
    private lazy var lastPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        return label
    }()
    
    /// 涨跌幅
    private lazy var rfRatioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        return label
    }()
    
    // 延时行情标签
    private lazy var delayLabel: QUMarketDelayLabel = {
        let label = QUMarketDelayLabel()
        label.isHidden = true
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
    
    func updateUI(model: QUHomeHotDealCellModel, index: Int) {
        stockNameLabel.text = model.stockName
        exchangeIcon.image = model.exchangeIcon
        if index < 3 {
            rankImageView.image = UIImage(bnNamed: "static_quote_hotdeal_rank_" + "\(index + 1)")
            rankImageView.isHidden = false
            rankLabel.isHidden = true
        } else {
            rankImageView.isHidden = true
            rankLabel.isHidden = false
            rankLabel.text = "\(index + 1)"
        }
        stockCodeLabel.text = model.stockCode
        lastPriceLabel.text = model.last
        rfRatioLabel.text = model.rfRatio
        lastPriceLabel.textColor = model.riseFallColor()
        rfRatioLabel.textColor = model.riseFallColor()
        delayLabel.isHidden = !model.isDelay
    }
    
}

extension QUHomeHotDealCell {
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(rankImageView)
        contentView.addSubview(rankLabel)
        contentView.addSubview(stockNameLabel)
        contentView.addSubview(exchangeIcon)
        contentView.addSubview(stockCodeLabel)
        contentView.addSubview(lastPriceLabel)
        contentView.addSubview(rfRatioLabel)
        contentView.addSubview(delayLabel)
        
        rankImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(8))
            make.top.equalToSuperview().offset(bnScaleFit(12))
            make.size.equalTo(CGSize(width: bnScaleFit(20), height: bnScaleFit(20)))
        }
        rankLabel.snp.makeConstraints { make in
            make.center.equalTo(rankImageView)
            make.height.equalTo(bnScaleFit(20))
        }
        stockNameLabel.snp.makeConstraints { make in
            make.left.equalTo(rankImageView.snp.right).offset(bnScaleFit(4))
            make.top.equalTo(rankImageView)
            make.height.equalTo(bnScaleFit(20))
            make.width.equalTo(bnScaleFit(125))
        }
        exchangeIcon.snp.makeConstraints { make in
            make.left.equalTo(stockNameLabel)
            make.centerY.equalTo(stockCodeLabel)
        }
        stockCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(stockNameLabel.snp.bottom)
            make.left.equalToSuperview().offset(bnScaleFit(52))
        }
        lastPriceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(104))
            make.centerY.equalToSuperview()
            make.width.equalTo(bnScaleFit(60))
        }
        rfRatioLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(12))
            make.centerY.equalToSuperview()
        }
        delayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(stockCodeLabel)
            make.left.equalTo(stockCodeLabel.snp.right).offset(4)
            make.size.equalTo(delayLabel.labelSize)
        }
    }
}
