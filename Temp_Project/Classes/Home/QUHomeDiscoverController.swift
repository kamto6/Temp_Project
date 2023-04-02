//
//  QUHomeDiscoverController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import UIKit
import BNUMain


class QUHomeDiscoverController: BNBaseTableViewController {

    //用户
    private lazy var userInfoView: QUHomeUserInfoView = {
        let view = QUHomeUserInfoView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kNaviTitleViewHeight))
        view.userLogoClickBlock = { [weak self] in
            guard let self = self else { return }
            self.userLogoClick()
        }
        return view
    }()
    
    // 响铃 按钮
    private lazy var bellView: BNButtonPointView = {
        let bellView = BNButtonPointView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        bellView.iconButton.setImage(UIImage(bnNamed: "static_main_top_nav_talk"), for: .normal)
        bellView.iconButton.addTarget(self, action: #selector(bellBtnClick), for: .touchUpInside)
        bellView.showPoint = NoticeCenterManager.sharedInstance.unreadMessageCount > 0
        return bellView
    }()
    
    /// 权限条
    private lazy var barViewController: BNQuotesBarViewController = .init(page: .watchList, exchange: .unKnow)
    
    /// timer
    private var timer: Timer?
    /// 定时器刷新间隔
    private var timerDuration: TimeInterval = 5.0
    /// 定时器开启时间戳
    private var timerStartStamp: TimeInterval = 0.0
    
    
    /// 滚动视图
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        return scrollView
    }()
    
    /// header 背景色
    private lazy var gradientLayer: BNGradientLayer = {
        let gradientLayer = BNGradientLayer()
        gradientLayer.colors = [
            UIColor.color(colorHexString: "#ffffff", alpha: 1).cgColor,
            UIColor.color(colorHexString: "#F5F6F7", alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        return gradientLayer
    }()
    
    /// 滚动视图上的容器
    private lazy var subControllerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    /// 底部容器
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    /// 底部行情权限说明标签
    private lazy var bottomLabel: QUDiscoverLevelTipBottomView = {
        let label = QUDiscoverLevelTipBottomView()
        return label
    }()
    
    private lazy var footerSpringView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /// 当前的导航栏颜色
    private lazy var currentNaviBarColor: UIColor = .white
    
    /// 子控制器
    private var componentModels = [QUHomeComponentModel]()
    
    private let kNaviTitleViewHeight: CGFloat = 44.0
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        trackingPage = QUTrackingEventPage.quotesMain.key
        setupNaviBar()
        initLocalData()
        setupUI()
        addNotifications()
        QPHomePageManager.sharedInstance.fetchHomeRankList {
            self.reloadComponents()
        }
        QPHomePageManager.sharedInstance.fetchCurrentExchange()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 请求未读消息
        NoticeCenterManager.sharedInstance.queryUnreadMessageCount()
        /// 开启定时器
        startTimer()
        /// 更新导航栏设置
        updateNaviBarWhenViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// 关闭定时器
        stopTimer()
    }
    
    /// App进入前台
    override func appWillEnterForeground() {
        super.appWillEnterForeground()
        if isCurrentVC {
            startTimer()
        }
    }
    
    /// App进入后台
    override func appDidEnterBackground() {
        super.appDidEnterBackground()
        if isCurrentVC {
            stopTimer()
        }
    }
    
    // MARK: - Publics

    // 下拉刷新
    override func headerRefresh() {
  
        QuoteLogger.debug("发现界面下拉刷新")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollView.mj_header?.endRefreshing()
        }
        for model in componentModels {
            if let controller = model.controller {
                /// 所有子模块，触发下拉刷新
                controller.headerRefresh()
            }
        }
    }
    
    override func monitoringInternet() {
        connectedToInternet()
            .skip(1)
            .subscribe(onNext: { [weak self] isReachable in
                guard let self = self else { return }
                if isReachable {
                    // 从无网到有网
                    for model in self.componentModels {
                        if let controller = model.controller {
                            /// 所有子模块，触发下拉刷新
                            controller.headerRefresh()
                        }
                    }
                    self.startTimer()
                } else {
                    // 从有网到无网
                    self.stopTimer()
                }
                
            })
            .disposed(by: disposeBag)
    }
    
}

extension QUHomeDiscoverController {
    
    // MARK: - Notifications
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(userNoticeUnreadCountDidChanged), name: NSNotification.Name(nkMainUserNoticeUnreadCountDidChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorChanged), name: NSNotification.Name(rawValue: nkQuoteColorChange), object: nil)
    }
    
    @objc private func userNoticeUnreadCountDidChanged() {
        bellView.showPoint = NoticeCenterManager.sharedInstance.unreadMessageCount > 0
    }
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupNaviBar() {
        /// 导航栏右边
        let bellItem = UIBarButtonItem(customView: bellView)
        navigationItem.rightBarButtonItem = bellItem
        navigationItem.titleView = userInfoView
    }
    
    private func updateNaviBarWhenViewWillAppear() {
        /// 更新导航栏颜色
        updateNaviBarColor(isScrolled: false)
        /// titleView 更新frame
        userInfoView.reloadFrame()
    }
    
    private func initLocalData() {
        componentModels = QUHomeDiscoverComponentProvider.getDefaultSubComponent()
    }
    
    private func setupUI() {
        view.backgroundColor = KhomeDiscoverBgColor
        addChild(barViewController)
        view.addSubview(barViewController.view)
        barViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        view.addSubview(scrollView)
        addMJHeader(scrollView)
        scrollView.mj_header?.isHidden = false
        scrollView.addSubview(subControllerStackView)
        scrollView.addSubview(bottomStackView)
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(barViewController.view.snp.bottom)
        }
        
        subControllerStackView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomStackView.snp.top)
        }
        /// 装配子模块
        for model in componentModels {
            if let controller = model.controller {
                self.addChild(controller)
                view.addSubview(controller.view)
                subControllerStackView.addArrangedSubview(controller.view)
            }
        }
        
        bottomStackView.addArrangedSubview(bottomLabel)
        bottomStackView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        view.addSubview(footerSpringView)
        footerSpringView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    /// 根据排序接口控制显隐
    private func reloadComponents() {
        if let list = QUHomeDiscoverComponentProvider.loadSubComponentTypes() {
            let list2 = componentModels.compactMap { return $0.type }
            let deletedList = list2.filter { return list.contains($0) == false }
            for type in deletedList {
                /// 需要删除的
                if let index = list2.firstIndex(where: { $0 == type }) {
                    if index < componentModels.count, let controller = componentModels[index].controller, children.contains(controller) {
                        controller.removeFromParent()
                        controller.view.removeFromSuperview()
                        subControllerStackView.removeArrangedSubview(controller.view)
                    }
                }
            }
            
            for (index, type) in list.enumerated() {
                if let targetIndex = list2.firstIndex(where: { $0 == type }) {
                    /// 已经存在的, 需要改变位置
                    if targetIndex < componentModels.count, let controller = componentModels[targetIndex].controller, subControllerStackView.subviews.contains(controller.view) {
                        subControllerStackView.insertArrangedSubview(controller.view, at: index)
                    }
                } else {
                    /// 需要新建的
                    if let model = QUHomeDiscoverComponentProvider.getSubComponent(with: type), let controller = model.controller {
                        addChild(controller)
                        view.addSubview(controller.view)
                        subControllerStackView.insertArrangedSubview(controller.view, at: index)
                    }
                }
            }
        }
    }
    
    
    /// 开启定时器
    private func startTimer() {
        /// 开启任务
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: timerDuration,
                                     target: self,
                                     selector: #selector(refreshData),
                                     userInfo: nil,
                                     repeats: true)
        
        if let timer = timer {
            timerStartStamp = Date().timeIntervalSince1970
            RunLoop.current.add(timer, forMode: .default)
        }
    }
    
    /// 关闭定时器
    private func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    ///  定时刷新数据
    @objc func refreshData() {
        QuoteLogger.debug("发现界面定时器刷新")
        let nowTimeStamp = Date().timeIntervalSince1970
        for model in componentModels {
            if let controller = model.controller {
                /// 所有子模块，触发定时器刷新
                /// 子模块刷新时间不是一致的
                /// 注意，这里规定子模块刷新的间隔必须是当前定时器间隔的倍数
                if let duration = controller.timerDuration(),
                   Int(duration) >= Int(timerDuration),
                   Int(duration) % Int(timerDuration) == 0,
                   Int(nowTimeStamp - timerStartStamp) >= Int(duration),
                   Int(nowTimeStamp - timerStartStamp) % Int(duration) == 0 {
                    controller.timerRefresh()
                }
            }
        }
    }
    
    /// 消息按钮点击
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
    
    /// 用户logo点击
    private func userLogoClick() {
        if let module = ServiceManager.sharedInstance.moduleByService(service: UserOpenService.self) as? UserOpenService {
            if module.isLogin() {
                if let controller = BNQuoteMainManager.shared.userUIService()?.getPersonInfoController() {
                    BNNavigationHelper.pushViewController(controller, animated: true)
                }
            } else {
                module.showLoginVc(toVc: self)
            }
        }
    }
    
    @objc private func colorChanged() {
        for model in componentModels {
            if let controller = model.controller {
                /// 所有子模块，触发下拉刷新
                controller.colorChanged()
            }
        }
    }
    
}

extension QUHomeDiscoverController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNaviBarColor(isScrolled: true)
        let offset = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height
        if offset < 0 {
            footerSpringView.snp.updateConstraints { make in
                make.height.equalTo(abs(offset))
            }
        } else {
            footerSpringView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
    }
    
    // 根据是否在滑动状态下更新导航栏颜色
    private func updateNaviBarColor(isScrolled: Bool = true) {
        let updateBlock: ((UIColor) -> Void) = { color in
            self.updateNaviBarColor(color)
            self.currentNaviBarColor = color
        }
        let isScrollTop = scrollView.contentOffset.y > 100
        let barTintColor = isScrollTop ? UIColor.white : KhomeDiscoverBgColor
        if isScrolled {
            if currentNaviBarColor != barTintColor {
                updateBlock(barTintColor)
            }
        } else {
            updateBlock(barTintColor)
        }
    }
    
    /// 根据颜色更新导航栏颜色
    private func updateNaviBarColor(_ barTintColor: UIColor) {
        let barTintImage = UIImage.image(color: barTintColor)
        navigationController?.navigationBar.setBackgroundImage(barTintImage, for: .default)
        navigationController?.navigationBar.shadowImage = barTintImage
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = barTintColor
            appearance.shadowColor = barTintColor
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
}

