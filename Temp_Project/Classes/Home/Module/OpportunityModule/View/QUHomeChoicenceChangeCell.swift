//
//  QUHomeChoicenceChangeCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation
import UIKit

class QUHomeChoicenceChangeCell: UITableViewCell {
    
    // MARK: - Properties
    
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
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = bnScaleFit(3)
        return view
    }()
    
    /// 变动值
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        return label
    }()
    
    /// 涨跌幅
    private lazy var rfRatioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        label.textColor = Quote_Gray3
        return label
    }()
    
    /// 变动规则
    private lazy var monitorNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        return label
    }()
    
    /// 时间
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        label.textColor = Quote_Gray3
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
    
    func updateUI(model: QUHomeChoicenceChangeCellModel) {
        stockNameLabel.text = model.stockName
        exchangeIcon.image = model.exchangeIcon
        exchangeIcon.isHidden = false
        stockCodeLabel.text = model.stockCode
        changeLabel.text = model.changeValue
        rfRatioLabel.text = (model.timeTypeDesc ?? "") + " " + (model.rfRatio ?? "--")
        monitorNameLabel.text = model.monitorName
        timeLabel.text = model.tradeTime
        
        changeLabel.textColor = model.riseFallColor()
        monitorNameLabel.textColor = model.riseFallColor()
    }
    
    func updateEmaptyUI() {
        stockNameLabel.text = "--"
        exchangeIcon.isHidden = true
        stockCodeLabel.text = "--"
        changeLabel.text = "--"
        rfRatioLabel.text = "--"
        monitorNameLabel.text = "---"
        timeLabel.text = "--"
        changeLabel.textColor = Quote_Flat_Color
        monitorNameLabel.textColor = Quote_Flat_Color
    }
    
}

extension QUHomeChoicenceChangeCell {
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(stockNameLabel)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(exchangeIcon)
        stackView.addArrangedSubview(stockCodeLabel)
        contentView.addSubview(rfRatioLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(monitorNameLabel)
        contentView.addSubview(timeLabel)
       
        stockNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.top.equalToSuperview().offset(bnScaleFit(12))
            make.height.equalTo(bnScaleFit(20))
            make.width.equalTo(bnScaleFit(125))
        }
        stackView.snp.makeConstraints { make in
            make.left.equalTo(stockNameLabel)
            make.top.equalTo(stockNameLabel.snp.bottom)
        }
        changeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(104))
            make.centerY.equalTo(stockNameLabel)
        }
        rfRatioLabel.snp.makeConstraints { make in
            make.right.equalTo(changeLabel)
            make.centerY.equalTo(stockCodeLabel)
        }
        monitorNameLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(12))
            make.centerY.equalTo(stockNameLabel)
        }
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(monitorNameLabel)
            make.centerY.equalTo(stockCodeLabel)
        }
    }
}

