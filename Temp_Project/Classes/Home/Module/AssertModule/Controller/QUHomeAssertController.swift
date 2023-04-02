//
//  QUHomeAssertController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import BNUMain

class QUHomeAssertController: BNBaseViewController {
    
    // MARK: - Properties
    
    /// 最外层容器
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 最外层容器高度
    private let kContainerHeight = bnScaleFit(160)
    
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

extension QUHomeAssertController: QUHomeComponentProtocol {
    
    func headerRefresh() {
        
        NotificationCenter.default.post(name: NSNotification.Name(nkTradeCardRefresh), object: nil)
    }
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        view.backgroundColor = KhomeDiscoverBgColor
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 获取交易模块的资产信息控制器
        if let controller = BNQuoteMainManager.shared.tradeUIService()?.getTradeAssetCardController() {
            addChild(controller)
            containerView.addSubview(controller.view)
            controller.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            controller.view.backgroundColor = KhomeDiscoverBgColor
        }
    }
    
}

