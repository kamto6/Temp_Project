//
//  QUNewsHotTopicCell.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation
import UIKit

class QUNewsHotTopicCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var topicDetailBlock: ((QUNewsHotTopicModel) -> Void)?
    var newsDetailBlock: ((QUNewsHotTopicModel, QUNewsListModel) -> Void)?
    
    private lazy var topBgImageView: UIImageView = {
        let view = UIImageView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(detailMoreClick))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 18)
        label.textColor = .white
        return label
    }()
    
    /// 查看主题
    private lazy var detailButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(bnNamed: "static_main_white_arrow"), for: .normal)
        button.setTitle(NSLocalizedString("进入主题", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.adjustImageTitlePosition(.right, spacing: 5)
        button.addTarget(self, action: #selector(detailMoreClick), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.dataSource = self
        view.delegate = self
        view.isScrollEnabled = false
        view.backgroundColor = Quote_White
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.register(QUNewsHotTopicListCell.self, forCellReuseIdentifier: "QUNewsHotTopicListCell")
        view.estimatedSectionFooterHeight = 0
        view.estimatedRowHeight = 0
        view.estimatedSectionHeaderHeight = 0
        view.rowHeight = bnScaleFit(bnScaleFit(52))
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
        gradientLayer.locations = [0, 0.62, 1]
        gradientLayer.frame = topBgImageView.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        topBgImageView.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    
    private lazy var imageViewMaskLayer: CAShapeLayer = {
        let maskPath = UIBezierPath(roundedRect: topBgImageView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: bnScaleFit(8), height: bnScaleFit(8)))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = topBgImageView.bounds
        maskLayer.path = maskPath.cgPath
        topBgImageView.layer.mask = maskLayer
        return maskLayer
    }()
    
    private var topicModel: QUNewsHotTopicModel?
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        /// 渐变色
        gradientLayer.frame = topBgImageView.bounds
        imageViewMaskLayer.frame = topBgImageView.bounds
        contentView.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
    }
    
    // MARK: - Publics
    
    func updateUI(model: QUNewsHotTopicModel) {
        topBgImageView.loadImage(urlStr: model.pictureURL ?? "", placeholder: nil)
        titleLabel.text = model.title
        topicModel = model
        tableView.reloadData()
    }
    
}

extension QUNewsHotTopicCell {
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        contentView.backgroundColor = Quote_White
        /// 阴影
        contentView.layer.shadowColor = UIColor.color(colorHexString: "#000000", alpha: 0.08).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 5
        
        /// 圆角
        contentView.layer.cornerRadius = bnScaleFit(16)
        
        contentView.addSubview(topBgImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailButton)
        contentView.addSubview(tableView)
        
        topBgImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(bnScaleFit(130))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.bottom.equalTo(topBgImageView.snp.bottom).offset(-bnScaleFit(16))
        }
        detailButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(12))
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(bnScaleFit(68))
            make.height.equalTo(bnScaleFit(bnScaleFit(30)))
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topBgImageView.snp.bottom).offset(bnScaleFit(4))
            make.bottom.equalToSuperview().offset(-bnScaleFit(16))
        }
    }
    
    @objc private func detailMoreClick() {
        if let topicModel = topicModel {
            topicDetailBlock?(topicModel)
        }
    }
    
}

extension QUNewsHotTopicCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = topicModel?.newsList?.count ?? 0
        return min(count, 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QUNewsHotTopicListCell", for: indexPath) as? QUNewsHotTopicListCell else {
            return UITableViewCell()
        }
        if let list = topicModel?.newsList, indexPath.row < list.count {
            cell.updatUI(with: list[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let topicModel = topicModel,  let list = topicModel.newsList, indexPath.row < list.count {
            newsDetailBlock?(topicModel, list[indexPath.row])
        }
    }
}


