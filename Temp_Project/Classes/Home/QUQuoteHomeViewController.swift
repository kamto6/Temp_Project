//
//  QUQuoteHomeViewController.swift
//  BNUQuoteTrade
//
//  Created by HuangShengJun on 2022/4/20.
//

import UIKit

class QUQuoteHomeViewController: BNBaseViewController {

    //搜索 按钮
    lazy var searchBtn: UIButton = {
        let searchBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        searchBtn.setImage(UIImage(bnNamed: "static_main_top_nav_search"), for: .normal)
        searchBtn.addTarget(self, action:  #selector(searchClick(_:)), for: .touchDown)
        searchBtn.contentHorizontalAlignment = .left
        return searchBtn
    }()
    // 响铃 按钮
    lazy var bellView: BNButtonPointView = {
        let bellView = BNButtonPointView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        bellView.iconButton.setImage(UIImage(bnNamed: "static_main_top_nav_talk"), for: .normal)
        bellView.iconButton.addTarget(self, action: #selector(bellBtnClick), for: .touchUpInside)
        bellView.showPoint = NoticeCenterManager.sharedInstance.unreadMessageCount > 0
        return bellView
    }()
    private let tabViewHeight: CGFloat = 44.0
    private let tabWidth: CGFloat = 44.0
    private let tabMargin: CGFloat = 17.0
    private let titles = [NSLocalizedString("自选", comment: ""), NSLocalizedString("香港", comment: ""), NSLocalizedString("美国", comment: "")]
    private lazy var tabLayout: BNUTabBarLayout = {
        let layout = BNUTabBarLayout.defaultLayout()
        layout.tabWidth = tabWidth
        layout.titleAlignment = .center
        layout.leftRightMargin = 0
        layout.tabMargin = tabMargin
        layout.lineColor = UIColor.palette.tertiaryBackground
        layout.lineTopSpace = tabViewHeight - layout.lineHeight
        return layout
    }()
    
    private lazy var tabView: BNUTabBar = {
        let tabView = BNUTabBar(frame: CGRect(x: 10.0, y: 0, width: CGFloat(titles.count) * (tabWidth + tabMargin) - tabMargin, height: tabViewHeight), with: self.tabLayout)
        tabView.backgroundColor = .white
        tabView.delegate = self
        tabView.layer.borderWidth = 0
        return tabView
    }()
    
    private lazy var pageView: BNUPageView = {
        let view = BNUPageView()
        view.contentView.isScrollEnabled = true
        view.contentView.bounces = false
        view.parentViewController = self
        view.backgroundColor = .clear
        view.contentView.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NoticeCenterManager.sharedInstance.queryUnreadMessageCount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackingPage = QUTrackingEventPage.quotesMain.key
        /// 导航栏右边
        let searchItem = UIBarButtonItem(customView: searchBtn)
        let bellItem = UIBarButtonItem(customView: bellView)
        navigationItem.rightBarButtonItems = [bellItem, searchItem]

        view.backgroundColor = Quote_BgColor

        navigationItem.titleView = {
            let navTitleView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: tabViewHeight))
            navTitleView.addSubview(tabView)
            return navTitleView
        }()
        
        view.addSubview(self.pageView)
        pageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()//.offset(BNUTabBarConstant.navBarHeight)
        }

        let watchListController = QUWatchlistViewController()
        let hkMarketListController = QUMarketListController(exchange: .HK)
        let usMarketListController = QUMarketListController(exchange: .US)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            watchListController.loadViewIfNeeded()
            // 预加载UI
            hkMarketListController.loadViewIfNeeded()
            usMarketListController.loadViewIfNeeded()
        }
        
        
        let titleItems = titles.enumerated().map { type -> BNUTabBarTitleItem in
            let item = BNUTabBarTitleItem()
            item.titleColor = Gray3
            item.titleSelectedColor = Gray1
            item.titleFont = UIFont.bnFont(fontStyle: .Regular, fontSize: 16)
            item.titleSelectedFont = UIFont.bnFont(fontStyle: .Semibold, fontSize: 24)
            item.title = type.element
            return item
        }
        pageView.viewControllers = [watchListController,hkMarketListController ,usMarketListController]
        tabView.titleItems = titleItems
        tabView.reloadData()
 
        NotificationCenter.default.addObserver(self, selector: #selector(userNoticeUnreadCountDidChanged), name: NSNotification.Name(nkMainUserNoticeUnreadCountDidChanged), object: nil)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BNDeviceHelper.switchDeviceInterfaceOrientatin(.portrait)
    }
    
    @objc private func searchClick(_ item: UIBarButtonItem) {
        let searchVC = QUSearchController.instance(config: BNSearchConfig(), delegate: self)
        present(searchVC, animated: true, completion: nil)
    }
    
    @objc private func bellBtnClick() {
        if let module = ServiceManager.sharedInstance.moduleByService(service: UserOpenService.self) as? UserOpenService {
            if module.isLogin() {
                MainTrackingHelper.trackEvent(AnalyticsEvent.clickMessageBox, parameters: [AnalyticsParameter.clickMessageBoxEntry: "1"], trackSource: .needMap)
                navigationController?.pushViewController(BNMessageViewController(), animated: true)
            } else {
                module.showLoginVc(toVc: self)
            }
        }
    }

}

extension QUQuoteHomeViewController: BNUTabBarDelegate {
    
    func tabBar(_ tabBar: BNUTabBar, didSelectedItemAt index: Int) {
        // 埋点
        QUTrackingHelper.tracking(with: .clickQuoteTopTab, parameters: [.clickQuoteTopTab_TabName:index + 1])
        
        QuoteLogger.info("QUQuoteHomeViewController,didSelectedItemAt:\(index)")
    }
    /// 修改pageView的contentOffset
    func tabBar(_ tabBar: BNUTabBar, pageContentOffsetWith index: Int, animated: Bool) {
        pageView.setCurrentIndex(index, animated: animated)
    }
    
}

extension QUQuoteHomeViewController: BNUPageViewDelegate {
    
    /// 通知代理，contentView已经发生偏移
    func pageView(_ pageView: BNUPageView, scrollViewDidChanged offset: CGPoint) {
        self.tabView.contentScrollViewDidChanged(offset, width: pageView.contentView.bounds.size.width)
    }
}

extension QUQuoteHomeViewController: BNSearchControllerDelegate {
    
    @objc private func userNoticeUnreadCountDidChanged() {
        bellView.showPoint = NoticeCenterManager.sharedInstance.unreadMessageCount > 0
    }
    
    func onClickCloseButton(controller: BNSearchController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func didSelectedItem(controller: BNSearchController, item: Any?) {
        guard let infoModel = item as? StockInfoModel,
              let exchangeValue = infoModel.exchange,
              let exchange = ExchangeType(rawValue: exchangeValue),
              let categoryValue = infoModel.categoryType,
              let category = CategoryType(rawValue: categoryValue)
        else { return }
        
        BNQuoteJumpHelper.jumpStockDetailVc(exchange: exchange, code: infoModel.code ?? "", categoryType: category)
    }
}
