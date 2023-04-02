//
//  QUHomePreferredCompanyCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation
import UIKit
import BNUMain

class QUHomePreferredCompanyCell: UICollectionViewCell {
    
    var followStockBlock: ((QUHomePreferredCompanyCellModel, QUHomePreferredCompanyCell) -> Void)?
    /// 股票名称
    private lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 14)
        label.textColor = Quote_Gray1
        label.numberOfLines = 2
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
    
    /// 关注按钮
    private lazy var followButton: BNIndicatorButton = {
        let button = BNIndicatorButton()
        button.setImage(UIImage(bnNamed: "static_main_icon_unfollow"), for: .normal)
        button.setImage(UIImage(bnNamed: "static_main_icon_follow"), for: .selected)
        button.addTarget(self, action: #selector(followClick(_:)), for: .touchUpInside)
        button.indicatorBackgroundColor = contentView.backgroundColor ?? UIColor.white
        return button
    }()
    
    /// 现价 涨跌幅
    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 12)
        return label
    }()
    
    /// 公司logo
    private lazy var companyImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = bnScaleFit(46) * 0.5
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 公司兜底logo
    private lazy var companyLogo: QUHomePreferredCompanyLogo = {
        let view = QUHomePreferredCompanyLogo()
        view.isHidden = true
        return view
    }()
        
    private lazy var triangleImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = bnScaleFit(2)
        return view
    }()
    
    // 延时行情标签
    private lazy var delayLabel: QUMarketDelayLabel = {
        let label = QUMarketDelayLabel()
        label.isHidden = true
        return label
    }()
    
    private var model: QUHomePreferredCompanyCellModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func updateUI(model: QUHomePreferredCompanyCellModel) {
        self.model = model
        stockNameLabel.text = model.stockName ?? "--"
        stockCodeLabel.text = (model.stockCode ?? "--") + "." + (model.exchange ?? .unKnow ).convertToString()
        if let hasFollow = model.hasFollow {
            followButton.isSelected = hasFollow
            followButton.isHidden = false
        } else {
            followButton.isHidden = true
        }
        delayLabel.isHidden = !model.isDelay
        changeLabel.text = model.rfRatio ?? "--"
        changeLabel.textColor = model.riseFallColor()
        companyLogo.isHidden = true
        companyImageView.loadImage(urlStr: model.logoURl ?? "", placeholder: nil) { [weak self] in
            guard let self = self else { return }
            self.companyLogo.content = model.enName
            self.companyLogo.isHidden = false
        }
        if let direction = model.direction {
            switch direction {
            case .rise:
                triangleImageView.isHidden = false
                triangleImageView.image = UIImage(bnNamed: "static_quote_triangle_rise")?.withRenderingMode(.alwaysTemplate)
                triangleImageView.tintColor = Quote_Up_Color
            case .fall:
                triangleImageView.isHidden = false
                triangleImageView.image = UIImage(bnNamed: "static_quote_triangle_fall")?.withRenderingMode(.alwaysTemplate)
                triangleImageView.tintColor = Quote_Down_Color
            case .flat:
                triangleImageView.isHidden = true
            }
        } else {
            triangleImageView.isHidden = true
        }
    }
    
    func updateEmptyUI() {
        stockNameLabel.text = "--"
        stockCodeLabel.text = "--"
        changeLabel.text = "--"
        triangleImageView.isHidden = true
        self.companyLogo.content = "--"
        companyLogo.isHidden = false
        companyImageView.loadImage(urlStr: "", placeholder: nil)
        followButton.isSelected = false
    }
    
    // 展示收藏股票的动画
    func showFollowAnimation() {
        followButton.isEnabled = false
        followButton.showIndicator()
    }
    
    // 隐藏收藏股票的动画
    func hideFollowAnimation() {
        followButton.isEnabled = true
        followButton.hideIndicator()
    }
    
    // 更新收藏股票按钮的选中状态
    func followButtonToggle() {
        followButton.isSelected.toggle()
    }
    
}

extension QUHomePreferredCompanyCell {
    
    // MARK: - Notifications
    
    // MARK: - Privates
    
    private func setupUI() {
        contentView.backgroundColor = kMyWatchListBgColor
        contentView.layer.cornerRadius = bnScaleFit(8)

        contentView.addSubview(followButton)
        contentView.addSubview(companyImageView)
        contentView.addSubview(companyLogo)
        contentView.addSubview(stockNameLabel)
        contentView.addSubview(stockCodeLabel)
        contentView.addSubview(delayLabel)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(triangleImageView)
        stackView.addArrangedSubview(changeLabel)
        
        followButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(bnScaleFit(8))
            make.right.equalToSuperview().offset(-bnScaleFit(8))
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        companyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(bnScaleFit(12))
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.size.equalTo(CGSize(width: bnScaleFit(46), height: bnScaleFit(46)))
        }
        companyLogo.snp.makeConstraints { make in
            make.edges.equalTo(companyImageView)
        }
        stockNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stockCodeLabel.snp.top)
            make.left.equalTo(stackView)
            make.right.equalToSuperview().offset(-bnScaleFit(6))
        }
        stockCodeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(bnScaleFit(-4))
            make.left.equalTo(stackView)
            make.height.equalTo(bnScaleFit(17))
        }
        delayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(stockCodeLabel)
            make.left.equalTo(stockCodeLabel.snp.right).offset(4)
            make.size.equalTo(delayLabel.labelSize)
        }
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.right.equalToSuperview().offset(-bnScaleFit(12))
            make.bottom.equalToSuperview().offset(-bnScaleFit(12))
            make.height.equalTo(bnScaleFit(17))
        }
        triangleImageView.snp.makeConstraints { make in
            make.width.equalTo(bnScaleFit(10))
            make.height.equalTo(bnScaleFit(10))
        }
    }
    
    @objc private func followClick(_ sender: UIButton) {
        guard let model = model else { return}
        followStockBlock?(model, self)
    }
    
}


