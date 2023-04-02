//
//  QUHomeOpportunityTrackController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation

class QUHomeOpportunityTrackController: BNBaseViewController {
    
    // MARK: - Properties
    
    /// 最外层容器
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 最外层容器高度
    private let kContainerHeight = bnScaleFit(424)
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 18)
        label.textColor = Quote_Gray1
        label.textAlignment = .left
        label.text = QUHomeComponentType.opportunityTrack.title
        return label
    }()
    
    private lazy var hotDealController = QUHomeHotDealController()
    private lazy var choicenceChangeController = QUHomeChoicenessChangeController()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private var refreshCount = 0
    
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

extension QUHomeOpportunityTrackController: QUHomeComponentProtocol {
    
    func headerRefresh() {
        hotDealController.headerRefresh()
        choicenceChangeController.headerRefresh()
    }
    
    func timerRefresh() {
        headerRefresh()
    }
    
    func timerDuration() -> TimeInterval? {
        return 15.0
    }
    
    func colorChanged() {
        hotDealController.colorChanged()
        choicenceChangeController.colorChanged()
    }
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(containerView)
        view.addSubview(scrollView)
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kContainerHeight)
            make.bottom.equalToSuperview()
        }
        
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(20))
            make.top.equalToSuperview().offset(bnScaleFit(16))
            make.height.equalTo(bnScaleFit(25))
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(titleLabel.snp.bottom).offset(bnScaleFit(11))
            make.height.equalTo(bnScaleFit(364))
        }
        
        addChild(hotDealController)
        addChild(choicenceChangeController)
        scrollView.addSubview(hotDealController.view)
        scrollView.addSubview(choicenceChangeController.view)
        
        let itemWidth = bnScaleFit(342)
        hotDealController.view.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.left.equalToSuperview().offset(bnScaleFit(12))
            make.width.equalTo(itemWidth)
            make.height.equalToSuperview()
        }
        choicenceChangeController.view.snp.makeConstraints { make in
            make.left.equalTo(hotDealController.view.snp.right)
            make.top.bottom.equalTo(scrollView)
            make.width.equalTo(itemWidth)
            make.height.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.contentSize = CGSize(width: itemWidth * 2.0 + bnScaleFit(12) * 2.0, height: 0)
        }
    }
    
}
