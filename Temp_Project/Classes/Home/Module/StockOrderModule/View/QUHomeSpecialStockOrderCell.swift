//
//  QUHomeSpecialStockOrderCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation
import UIKit
import BNPAPI

class QUHomeSpecialStockOrderCell: UICollectionViewCell {
    
    var stockDetailBlock: ((StockQueryParameter) -> Void)?
    
    /// 股单名称
    private lazy var orderNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 16)
        label.textColor = Quote_Gray1
        label.text = "做空类ETF"
        return label
    }()
    
    /// 股票数
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = NSLocalizedString("包含股票数", comment: "")
        return label
    }()
    
    private lazy var representLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        label.textColor = Quote_Gray3
        label.text = NSLocalizedString("代表股票", comment: "")
        return label
    }()
    
    private lazy var orderBgView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var orderImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var stockPriceView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.color(colorHexString: "#F8F9FA")
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapStockAction(_:)))
        addGestureRecognizer(tap)
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var rfRatioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 12)
        return label
    }()
    
    private lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 12)
        label.textColor = Quote_Gray3
        return label
    }()
    
    private lazy var bottomRightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()
    
    private lazy var gradientLayer: BNGradientLayer = {
        let gradientLayer = BNGradientLayer()
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = CGRect(origin: .zero, size: imageSize)
        gradientLayer.startPoint = CGPoint(x: 0.58, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1.13, y: 1.13)
        gradientLayer.cornerRadius = bnScaleFit(6)
        orderBgView.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()

    private let imageSize = CGSize(width: bnScaleFit(48), height: bnScaleFit(48))
    private var model: QUHomeHotStockOrderCellModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func updateUI(model: QUHomeHotStockOrderCellModel) {
        self.model = model
        orderNameLabel.text = model.orderName
        let orderCount = "\(model.orderCount ?? 0)"
        let countAttriText = NSMutableAttributedString(string: NSLocalizedString("包含股票数", comment: "") + " " + orderCount, attributes: [.foregroundColor: Quote_Gray3, .font: UIFont.bnFont(fontStyle: .Regular, fontSize: 12)])
        countAttriText.addAttributes([.foregroundColor: Quote_Gray1, .font: UIFont.bnFont(fontStyle: .Medium, fontSize: 12)], range: NSRange(location: countAttriText.length - orderCount.length, length: orderCount.length))
        countLabel.attributedText = countAttriText
        orderImageView.loadImage(urlStr: model.pictureURL ?? "", placeholder: UIImage(bnNamed: "static_quote_stock_order_placeholder"))
        stockNameLabel.text = model.relatedStockName
        rfRatioLabel.text = model.relatedRfRatio
        rfRatioLabel.textColor = model.riseFallColor()
        
        if let headColor = model.headColor, let footColor = model.footColor {
            let headCgColor = UIColor.color(colorHexString: headColor).cgColor
            let footCgColor = UIColor.color(colorHexString: footColor).cgColor
            gradientLayer.colors = [headCgColor, footCgColor]
        }
        if orderNameLabel.isSkeletonable {
            skeletonAnimationHide()
        }
    }
    
    func updateEmptyUI() {
        self.orderImageView.image = UIImage(bnNamed: "static_quote_stock_order_placeholder")
        skeletonAnimationShow()
    }
    
    
}

extension QUHomeSpecialStockOrderCell {
    
    // MARK: - Notifications
    
    // MARK: - Privates
    
    private func setupUI() {
        contentView.backgroundColor = .white
     
        contentView.addSubview(orderBgView)
        contentView.addSubview(orderImageView)
        contentView.addSubview(orderNameLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(representLabel)
        contentView.addSubview(bottomRightLabel)
        contentView.addSubview(stockPriceView)
        stockPriceView.addSubview(stockNameLabel)
        stockPriceView.addSubview(rfRatioLabel)
        
        orderBgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(bnScaleFit(2))
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.size.equalTo(imageSize)
        }
        orderImageView.snp.makeConstraints { make in
            make.edges.equalTo(orderBgView)
        }
        orderNameLabel.snp.makeConstraints { make in
            make.top.equalTo(orderImageView.snp.top).offset(bnScaleFit(3))
            make.left.equalTo(orderImageView.snp.right).offset(bnScaleFit(13))
            make.height.equalTo(bnScaleFit(22))
            make.width.lessThanOrEqualTo(84)
        }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(orderNameLabel.snp.bottom).offset(bnScaleFit(4))
            make.left.equalTo(orderNameLabel)
            make.height.equalTo(bnScaleFit(17))
            make.width.lessThanOrEqualTo(84)
        }
        representLabel.snp.makeConstraints { make in
            make.centerY.equalTo(orderNameLabel)
            make.right.equalToSuperview()
            make.height.equalTo(bnScaleFit(17))
            make.width.equalTo(84)
        }
        bottomRightLabel.snp.makeConstraints { make in
            make.centerY.equalTo(countLabel)
            make.right.equalToSuperview()
            make.height.equalTo(bnScaleFit(17))
            make.width.equalTo(84)
        }
        stockPriceView.snp.makeConstraints { make in
            make.right.equalTo(representLabel)
            make.top.equalTo(representLabel.snp.bottom).offset(bnScaleFit(4))
            make.height.equalTo(bnScaleFit(22))
        }
        rfRatioLabel.snp.makeConstraints { make in
            make.right.equalTo(-bnScaleFit(4))
            make.centerY.equalToSuperview()
        }
        stockNameLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(bnScaleFit(72))
            make.left.equalTo(bnScaleFit(4))
            make.right.equalTo(rfRatioLabel.snp.left).offset(bnScaleFit(-bnScaleFit(4)))
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func tapStockAction(_ recognizer: UITapGestureRecognizer) {
        if let model = model, let exchange = model.exchange, let stockCode = model.relatedStockCode {
            let stock = StockQueryParameter(exchange: exchange, stockCode: stockCode, categoryType: .mainBoard)
            stockDetailBlock?(stock)
        }
    }
    
    private func skeletonAnimationShow() {
        delay { [weak self] in
            guard let self = self else { return }
            self.orderNameLabel.isSkeletonable = true
            self.orderNameLabel.skeletonTextLineHeight = .fixed(14)
            self.orderNameLabel.linesCornerRadius = 7
            self.orderNameLabel.showSkeletonAnimation()

            self.countLabel.isSkeletonable = true
            self.countLabel.skeletonTextLineHeight = .fixed(14)
            self.countLabel.linesCornerRadius = 7
            self.countLabel.showSkeletonAnimation()

            self.representLabel.isSkeletonable = true
            self.representLabel.skeletonTextLineHeight = .fixed(14)
            self.representLabel.linesCornerRadius = 7
            self.representLabel.showSkeletonAnimation()

            // 与约束设置的宽度、textAlignment有关
            self.bottomRightLabel.isSkeletonable = true
            self.bottomRightLabel.skeletonTextLineHeight = .fixed(14)
            self.bottomRightLabel.linesCornerRadius = 7
            self.bottomRightLabel.showSkeletonAnimation()

            self.stockPriceView.isHidden = true
        }
    }
    
    private func skeletonAnimationHide() {
        stockNameLabel.hideSkeletonAnimation()
        countLabel.hideSkeletonAnimation()
        representLabel.hideSkeletonAnimation()
        bottomRightLabel.hideSkeletonAnimation()
        stockPriceView.isHidden = false
    }
    
}
