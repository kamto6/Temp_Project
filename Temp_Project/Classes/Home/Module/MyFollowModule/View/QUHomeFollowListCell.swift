//
//  QUHomeFollowListCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation
import UIKit
import BNPAPI

class QUHomeFollowListCell: UICollectionViewCell {
    
    /// 股票名称
    private lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        label.textColor = Quote_Gray1
        return label
    }()
    
    /// 股票代码
    private lazy var stockCodeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        label.textColor = Quote_Gray3
        return label
    }()
    
    /// 是否持仓
    private lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 10)
        label.textColor = Quote_Gray3
        label.text = NSLocalizedString("持仓", comment: "")
        label.layer.borderColor = Quote_Gray3.cgColor
        label.layer.borderWidth = 0.5
        label.layer.cornerRadius = 2
        label.isHidden = true
        return label
    }()
    
    /// 现价 涨跌幅
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        return label
    }()
    
    // 延时行情标签
    private lazy var delayLabel: QUMarketDelayLabel = {
        let label = QUMarketDelayLabel()
        label.isHidden = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = bnScaleFit(2)
        return view
    }()
    
    /// 火花图
    private lazy var mlineView: UIView = {
        let view = UIView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func updateUI(model: QUHomeFollowListCellModel) {
        stockNameLabel.text = model.stockName ?? "--"
        stockCodeLabel.text = (model.stockCode ?? "--") + "." + (model.exchange ?? .unKnow ).convertToString()
        positionLabel.isHidden = !(model.hasPosition == true)
        delayLabel.isHidden = !model.isDelay
//        changeLabel.text = (model.last ?? "--") + "  " + (model.rfRatio ?? "--")
        changeLabel.text = model.rfRatio ?? "--"
        changeLabel.textColor = model.riseFallColor()
    }
   
    /// 火花图
    func drawSparkLines(mlines: [KlineMinData], model: QUHomeFollowListCellModel) {
        let exchange = model.exchange ?? .unKnow
        mlineView.layer.removeAllSublayers()
        let frame = CGRect(x: 0, y: 0, width: bnScaleFit(82), height: bnScaleFit(52))
        if mlines.count <= 0 {
            let layer = BNStockIndexTool().getPreColosePriceLayer(sectionFrame: frame, exchange: .US)
            mlineView.layer.addSublayer(layer)
        } else {
            let layer = BNStockIndexTool().getStockIndexLayer(data: mlines, sectionFrame: frame, exchange: exchange, updown: model.rfRatio ?? "")
            mlineView.layer.addSublayer(layer)
        }
    }
    
}

extension QUHomeFollowListCell {
    
    // MARK: - Notifications
    
    // MARK: - Privates
    
    private func setupUI() {
        contentView.backgroundColor = kMyWatchListBgColor
        contentView.layer.cornerRadius = bnScaleFit(8)

        contentView.addSubview(mlineView)
        contentView.addSubview(stockNameLabel)
        contentView.addSubview(stockCodeLabel)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(positionLabel)
        stackView.addArrangedSubview(delayLabel)
        contentView.addSubview(changeLabel)
        
        mlineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(bnScaleFit(17))
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.size.equalTo(CGSize(width: bnScaleFit(82), height: bnScaleFit(52)))
        }
        stockNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(bnScaleFit(12))
            make.left.equalTo(mlineView.snp.right).offset(bnScaleFit(12))
            make.right.equalToSuperview().offset(-bnScaleFit(12))
            make.height.equalTo(bnScaleFit(22))
        }
        stockCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(stockNameLabel.snp.bottom)
            make.left.equalTo(stockNameLabel)
            make.height.equalTo(bnScaleFit(17))
        }
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(stockCodeLabel)
            make.left.equalTo(stockCodeLabel.snp.right).offset(bnScaleFit(4))
            make.height.equalTo(bnScaleFit(17))
        }
        positionLabel.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 14))
        }
        delayLabel.snp.makeConstraints { make in
            make.size.equalTo(delayLabel.labelSize)
        }
        changeLabel.snp.makeConstraints { make in
            make.left.equalTo(stockNameLabel)
            make.right.equalToSuperview().offset(-bnScaleFit(6))
            make.top.equalTo(stockCodeLabel.snp.bottom).offset(bnScaleFit(4))
        }
    }
    
}

