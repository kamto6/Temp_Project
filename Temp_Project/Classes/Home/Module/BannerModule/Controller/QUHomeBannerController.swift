//
//  QUHomeBannerController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation

class QUHomeBannerController: BNBaseViewController {
    
    // MARK: - Properties
    
    /// 最外层容器
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 最外层容器高度
    private let kContainerHeight = bnScaleFit(116)
    
    /// 轮播图
    private lazy var cycleScrollView: QUBannerView = {
        let view = QUBannerView()
        view.delegate = self
        return view
    }()
    
    private lazy var pageControl: QUPageControl = {
        let control = QUPageControl()
        control.currentWidthMultiple = 1.8
        control.pointSize = CGSize.init(width: 5, height: 5)
        control.pointSpace = 5
        control.otherColor = UIColor.white.withAlphaComponent(0.5)
        control.currentColor = UIColor.white
        return control
    }()
    
    var bannerModels = [QUHomeBannerModel]() {
        didSet {
            let list = bannerModels.map { $0.bannerUrl ?? "" }
            cycleScrollView.bindDatas(with: list)
            pageControl.numberOfPages = bannerModels.count
            pageControl.reloadData()
        }
    }
    
    // MARK: - Init

    deinit {
        
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCacheData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHomeDiscoverBannerList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Publics
    
}

extension QUHomeBannerController: QUHomeComponentProtocol {
    
    func headerRefresh() {
        fetchHomeDiscoverBannerList()
    }
    
    private func fetchHomeDiscoverBannerList() {
        QPHomeRequestManager.fetchHomeDiscoverBannerList(position: 0).subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现请求banner列表失败，\(error.localizedDescription)")
            case .success(let response):
                self.bannerModels = response
                BNUserDefaultsStorage.setStructArray(response, forKey: QUUserStorageKey.discoverBannerList.appendUserId())
            }
            self.reloadContainerState()
        }).disposed(by: disposeBag)
    }
    
    /// 缓存
    private func loadCacheData() {
        let list = BNUserDefaultsStorage.structArrayData(QUHomeBannerModel.self, forKey: QUUserStorageKey.discoverBannerList.appendUserId())
        self.bannerModels = list
    }
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kContainerHeight)
            make.bottom.equalToSuperview().offset(bnScaleFit(-8))
        }
        containerView.addSubview(cycleScrollView)
        cycleScrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(bnScaleFit(100))
            make.centerY.equalToSuperview()
        }
        containerView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(cycleScrollView.snp.bottom).offset(-bnScaleFit(4))
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(6)
        }
    }
    
    /// 有数据时显示该卡片，无数据时卡片隐藏
    private func reloadContainerState() {
        view.isHidden = bannerModels.count <= 0
    }
    
}

extension QUHomeBannerController: QUBannerViewDelegate {
    
    func bannerView(_ bannerView: QUBannerView, didScrollTo index: Int) {
        pageControl.currentPage = index
    }
    
    func bannerView(_ bannerView: QUBannerView, didSelectItemAt index: Int) {
        if index < bannerModels.count {
            let itemModel = bannerModels[index]
            if let url = itemModel.forwardUrl, let tag = itemModel.tag, tag != 0 {
                URLHelper.sharedInstance.jumpToBindController(urlString: url, extraParams: nil, operation: .push, animated: true)
            }
        }
    }
}

