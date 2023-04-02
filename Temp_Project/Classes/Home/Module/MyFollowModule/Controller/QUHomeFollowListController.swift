//
//  QUHomeFollowListController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import UIKit

class QUHomeFollowListController: BNBaseViewController {
    
    // MARK: - Properties
    
    /// 最外层容器
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var cornerRadiusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = bnScaleFit(16)
        view.backgroundColor = UIColor.palette.background
        return view
    }()
    
    /// 最外层容器高度
    private let kContainerHeight = bnScaleFit(146)
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 18)
        label.textColor = Quote_Gray1
        label.textAlignment = .left
        label.text = QUHomeComponentType.followlist.title
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
    
    /// 左右边距、item之间的间距
    private let marginSpace: CGFloat = 12
    private let itemWidth = bnScaleFit(212)
    private let itemHeight = bnScaleFit(82)
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout() // UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = marginSpace
        layout.minimumInteritemSpacing = marginSpace
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.palette.background
        view.contentInset = UIEdgeInsets(top: 0, left: bnScaleFit(20), bottom: 0, right: bnScaleFit(20))
        view.delegate = self
        view.dataSource = self
        view.bounces = true
        view.register(QUHomeFollowListCell.self, forCellWithReuseIdentifier: "QUHomeFollowListCell")
        view.register(QUHomeFollowFooterCell.self, forCellWithReuseIdentifier: "QUHomeFollowFooterCell")
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    /// 空页面
    private lazy var emptyView: QUHomeFollowEmptyView = {
        let view = QUHomeFollowEmptyView()
        view.layer.cornerRadius = bnScaleFit(10)
        view.isHidden = true
        view.tapActionBlock = { [weak self] in
            guard let self = self else { return }
            self.enterPreferredCompanyListVC()
        }
        return view
    }()
    
    /// 网络失败
    private lazy var failView: QUHomeFollowNoNetWorkView = {
        let view = QUHomeFollowNoNetWorkView()
        view.layer.cornerRadius = bnScaleFit(10)
        view.tapActionBlock = { [weak self] in
            guard let self = self else { return }
            self.fetchHomeFollowList()
        }
        return view
    }()
    
    private let dataManager = QUHomeFollowListDataManager()
    private var dataList: [QUHomeFollowListCellModel] {
        return dataManager.getHomeDicoverFollowList()
    }
    
    // MARK: - Init
    
    deinit {
        
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initData()
        addNotifications()
        dataManager.loadCacheData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHomeFollowList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubcriptStocks()
    }
    
    // MARK: - Publics
    
}

extension QUHomeFollowListController: QUHomeComponentProtocol {
    
    func headerRefresh() {
        fetchHomeFollowList()
    }
    
    func colorChanged() {
        collectionView.reloadData()
    }
    
    // MARK: - Notifications
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnect), name: NSNotification.Name(rawValue: nkMainQuoteSocketLoginSucceed), object: nil)
        // 添加自选股票
        QUWatchlistDataManager.shared.insertSucceedSubject.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.fetchHomeFollowList()
        }).disposed(by: self.disposeBag)
        // 删除自选股票
        QUWatchlistDataManager.shared.deleteSucceedSubject.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.fetchHomeFollowList()
        }).disposed(by: self.disposeBag)
    }
    
    @objc private func socketConnect() {
        dataManager.unSubcriptStocks()
        dataManager.subcriptStocks()
    }
    
    // MARK: - Privates
    
    private func setupUI() {
        view.backgroundColor = KhomeDiscoverBgColor
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kContainerHeight)
            make.bottom.equalToSuperview()
        }
        containerView.addSubview(cornerRadiusView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailButton)
        containerView.addSubview(collectionView)
        containerView.addSubview(emptyView)
        
        cornerRadiusView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(bnScaleFit(16))
        }
        
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
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(bnScaleFit(15))
            make.height.equalTo(bnScaleFit(82))
        }
        emptyView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(20))
            make.right.equalToSuperview().offset(-bnScaleFit(20))
            make.top.equalTo(titleLabel.snp.bottom).offset(bnScaleFit(15))
            make.height.equalTo(bnScaleFit(82))
        }
    }
    
    private func initData() {
        dataManager.requestSuccessBlock = { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.emptyView.isHidden = self.dataList.count > 0
            self.showFailView(false)
            self.collectionView.isHidden = !self.emptyView.isHidden
        }
        dataManager.requestfailureBlock = { [weak self] error in
            guard let self = self else { return }
            if self.dataList.count <= 0 {
                self.showFailView(true)
            }
        }
        dataManager.socketQuoteSnaptDataBlock = { [weak self] index in
            guard let self = self else { return }
            if let cell = self.getCurrentCollectCell(with: index) {
                cell.updateUI(model: self.dataList[index])
            }
        }
        dataManager.socketQuoteSparkDataBlock = { [weak self] index in
            guard let self = self else { return }
            if let cell = self.getCurrentCollectCell(with: index), index < self.dataList.count {
                let item = self.dataList[index]
                cell.drawSparkLines(mlines: self.dataManager.getSparkData(with: item.stockCode), model:item)
            }
        }
    }
    
    private func getCurrentCollectCell(with index: Int) -> QUHomeFollowListCell? {
        /// 对屏幕内的cell进行刷新
        let curRow = IndexPath(row: index, section: 0)
        if self.collectionView.indexPathsForVisibleItems.contains(curRow) {
            if let cell = collectionView.cellForItem(at: curRow) as? QUHomeFollowListCell,
                index < dataList.count {
                return cell
            }
        }
        return nil
    }
    
    @objc private func detailMoreClick() {
        (self.tabBarController as? MainTabBarController)?.setCurrentSelectedIndex(type: .Quote)
    }
    
    private func enterPreferredCompanyListVC() {
        QUFlutterHelper.shared.jumpToFlutterController(.companyList)
    }
    
    private func addStockAction() {
        if BNQuoteMainManager.shared.isLogin() {
            QUTrackingHelper.tracking(with: .clickAddSymbol, parameters: [:])
            let searchController = QUSearchController.instance(config: BNSearchConfig(), delegate: nil)
            present(searchController, animated: true, completion: {})
        } else {
            QUTrackingHelper.tracking(with: .clickAddSymbolLogin, parameters: [:])
            BNQuoteJumpHelper.jumpLoginController()
        }
    }
    
}


extension QUHomeFollowListController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < self.dataList.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QUHomeFollowListCell", for: indexPath) as? QUHomeFollowListCell else {
                return UICollectionViewCell()
            }
            let item = dataList[indexPath.row]
            cell.updateUI(model: item)
            cell.drawSparkLines(mlines: dataManager.getSparkData(with: item.stockCode), model:item)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QUHomeFollowFooterCell", for: indexPath) as? QUHomeFollowFooterCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataList.count > 0 {
            return dataList.count < dataManager.maxShowCount ? dataList.count + 1 : dataList.count
        } else {
            return dataList.count
        }
    }
    
}

extension QUHomeFollowListController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.row < dataList.count {
            QUTrackingHelper.tracking(with: .clickJumpTracepStockPage, parameters: [:])
            let item = dataList[indexPath.row]
            let stockCode = item.stockCode ?? ""
            let exchange = item.exchange ?? .HK
            BNQuoteJumpHelper.jumpStockDetailVc(exchange: exchange, code: stockCode, categoryType: .mainBoard)
        } else {
            enterPreferredCompanyListVC()
        }
    }
}

extension QUHomeFollowListController {
    
    /// 请求我的关注数据
    private func fetchHomeFollowList() {
        if dataList.count <= 0 && isReachableToInternet() == false {
            showFailView(true)
        }
        dataManager.fetchHomeDiscoverFollowList()
    }
    
    /// 取消订阅数据
    func unSubcriptStocks() {
        dataManager.unSubcriptStocks()
    }
    
    private func showFailView(_ isShow: Bool) {
        if isShow {
            if failView.superview == nil {
                view.addSubview(failView)
                failView.snp.makeConstraints { make in
                    make.edges.equalTo(emptyView)
                }
            }
            view.bringSubviewToFront(failView)
        } else {
            if let item = view.subviews.filter({ ($0 is QUHomeFollowNoNetWorkView) }).first {
                item.removeFromSuperview()
            }
        }
    }
    
}
