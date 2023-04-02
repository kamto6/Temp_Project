//
//  QUHomeHotNewsController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import BNUMain

class QUHomeHotNewsController: BNBaseViewController {
    
    // MARK: - Properties
    
    /// 最外层容器
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 最外层容器高度
    private let kContainerHeight = bnScaleFit(440)
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 18)
        label.textColor = Quote_Gray1
        label.textAlignment = .left
        label.text = QUHomeComponentType.hotNews.title
        return label
    }()
    
    /// 查看更多
    private lazy var detailButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(bnNamed: "static_quote_seemore_right_arrow"), for: .normal)
        button.setTitle(NSLocalizedString("更多", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 14)
        button.setTitleColor(Gray3, for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.adjustImageTitlePosition(.right, spacing: 5)
        button.addTarget(self, action: #selector(detailMoreClick), for: .touchUpInside)
        return button
    }()
    
    private lazy var flashController = QUNewsFlashController()
    private lazy var hotTopicController = QUNewsHotTopicControlller()
    
    // MARK: - Init
    
    deinit {
        
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Publics
    
}

extension QUHomeHotNewsController: QUHomeComponentProtocol {
    
    func headerRefresh() {
        flashController.headerRefresh()
        hotTopicController.headerRefresh()
    }
    
    func timerRefresh() {
        flashController.timerRefresh()
    }
    
    func timerDuration() -> TimeInterval? {
        return 60.0
    }
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailButton)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(20))
            make.top.equalToSuperview().offset(bnScaleFit(16))
            make.height.equalTo(bnScaleFit(25))
        }
        detailButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(20))
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        
        addChild(flashController)
        addChild(hotTopicController)
        hotTopicController.reloadSuperViewUIBlock = { [weak self] count in
            guard let self = self else { return }
            /// 有数据时显示该卡片，无数据时卡片隐藏
            self.view.isHidden = count <= 0
        }
        containerView.addSubview(flashController.view)
        containerView.addSubview(hotTopicController.view)
        
        flashController.view.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(bnScaleFit(11))
            make.left.right.equalToSuperview()
            make.height.equalTo(bnScaleFit(76))
        }
        hotTopicController.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(flashController.view.snp.bottom).offset(bnScaleFit(8))
            make.height.equalTo(bnScaleFit(330))
            make.bottom.equalToSuperview()
        }
    }

    @objc private func detailMoreClick() {
        URLHelper.sharedInstance.jumpToBindController(urlString: InformationUrlOnTab, extraParams: nil, operation: .push, animated: true)
    }
    
}
