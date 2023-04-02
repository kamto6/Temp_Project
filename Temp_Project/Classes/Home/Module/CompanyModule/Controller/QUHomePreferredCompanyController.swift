//
//  QUHomePreferredCompanyController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import UIKit
import BNUMain

class QUHomePreferredCompanyController: BNBaseViewController {
    
    // MARK: - Properties
    
    /// 最外层容器
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 最外层容器高度
    private let kContainerHeight = bnScaleFit(350)
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 18)
        label.textColor = Quote_Gray1
        label.textAlignment = .left
        label.text = QUHomeComponentType.preferredCompany.title
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
    
    /// 请求失败
    private var hadRequestedFail = false
    
    /// 最多展示的item个数
    private let maxShowCount: Int = 20
    /// 左右边距、item之间的间距
    private let marginSpace: CGFloat = 12
    private let itemWidth = bnScaleFit(102)
    private let itemHeight = bnScaleFit(148)
    /// 已经获取到当前的交易市场
    private var hadGetCurrentExchange = false
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    private lazy var hkMarketIndexView: QUHomeMarketIndexView = {
        let view = QUHomeMarketIndexView(frame: .zero, exchange: .HK, indexTypeList: dataManager.indexTypeMap[.HK] ?? [])
        view.delegate = self
        return view
    }()
    
    private lazy var usMarketIndexView: QUHomeMarketIndexView = {
        let view = QUHomeMarketIndexView(frame: .zero, exchange: .US, indexTypeList: dataManager.indexTypeMap[.US] ?? [])
        view.delegate = self
        return view
    }()
    
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = marginSpace
        layout.minimumInteritemSpacing = marginSpace
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: bnScaleFit(20), bottom: 0, right: bnScaleFit(20))
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.palette.background
        view.delegate = self
        view.dataSource = self
        view.bounces = true
        view.register(QUHomePreferredCompanyCell.self, forCellWithReuseIdentifier: "QUHomePreferredCompanyCell")
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var pageControl: QUPageControl = {
        let control = QUPageControl()
        control.numberOfPages = 2
        control.currentWidthMultiple = 1.8
        control.pointSize = CGSize.init(width: 5, height: 5)
        control.pointSpace = 5
        control.otherColor = UIColor.color(colorHexString: "#878D9A").withAlphaComponent(0.5)
        control.currentColor = UIColor.color(colorHexString: "#878D9A")
        control.reloadData()
        return control
    }()
    
    private let dataManager = QUHomeCompanyDataManager()
    
    private var dataList: [QUHomePreferredCompanyCellModel] {
        return dataManager.getHomeDicoverCompanyList()
    }
    
    // MARK: - Init
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initData()
        addNotifications()
        dataManager.loadCacheData()
        fetchPreferredCompanyList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataManager.subcriptAllStocks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataManager.unSubcriptAllStocks()
    }
    
}

extension QUHomePreferredCompanyController: QUHomeComponentProtocol {
    
    func headerRefresh() {
        fetchPreferredCompanyList()
    }
    
    func colorChanged() {
        hkMarketIndexView.colorChanged()
        usMarketIndexView.colorChanged()
        collectionView.reloadData()
    }
    
    // MARK: - Notifications
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnect), name: NSNotification.Name(rawValue: nkUpdateUserMarketAuthLevel), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentExchange), name: NSNotification.Name(rawValue: nkDidGetCurrentExchangeNoti), object: nil)
        // 添加自选股票
        QUWatchlistDataManager.shared.insertSucceedSubject.subscribe(onNext: { [weak self] insertModel in
            guard let self = self else { return }
            var stockModels = insertModel.insertedList.map { return QUStockModel(exchange: $0.exchange ?? .unKnow, stockCode: $0.code ?? "", categoryType: $0.categoryType ?? .mainBoard)}
            stockModels = stockModels.filter { $0.stockCode.length > 0 && $0.exchange != .unKnow  }
            self.updateCollectState(stockModels: stockModels, hasFollow: true)
    
        }).disposed(by: self.disposeBag)
        // 删除自选股票
        QUWatchlistDataManager.shared.deleteSucceedSubject.subscribe(onNext: { [weak self] deletedList in
            guard let self = self else { return }
            var stockModels = deletedList.map { return QUStockModel(exchange: $0.exchange ?? .unKnow, stockCode: $0.code ?? "", categoryType: $0.categoryType ?? .mainBoard)}
            stockModels = stockModels.filter { $0.stockCode.length > 0 && $0.exchange != .unKnow  }
            self.updateCollectState(stockModels: stockModels, hasFollow: false)
        }).disposed(by: self.disposeBag)
    }
    
    /// 更新收藏状态
    private func updateCollectState(stockModels: [QUStockModel], hasFollow: Bool) {
        dataManager.updateCollectState(stockModels: stockModels, hasFollow: hasFollow)
    }
    
    @objc private func socketConnect() {
        dataManager.unSubcriptAllStocks()
        dataManager.subcriptAllStocks()
    }
    
    @objc private func updateCurrentExchange() {
        if let exchange = QPHomePageManager.sharedInstance.exchange, !hadGetCurrentExchange {
            hadGetCurrentExchange = true
            dataManager.currentExchange = exchange
            let page = exchange.rawValue - 1
            scrollView.contentOffset = CGPoint(x: CGFloat(page) * scrollView.width, y: 0)
            pageControl.currentPage = page
            collectionView.reloadData()
        }
    }
    
    // MARK: - Privates
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kContainerHeight)
            make.bottom.equalToSuperview()
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailButton)
        containerView.addSubview(scrollView)
        containerView.addSubview(collectionView)
        
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
            make.bottom.equalToSuperview().offset(-bnScaleFit(8))
            make.height.equalTo(bnScaleFit(148))
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(bnScaleFit(15))
            make.height.equalTo(bnScaleFit(106))
        }
        
        scrollView.addSubview(hkMarketIndexView)
        scrollView.addSubview(usMarketIndexView)
        
        hkMarketIndexView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView)
        }
        usMarketIndexView.snp.makeConstraints { make in
            make.left.equalTo(hkMarketIndexView.snp.right)
            make.top.bottom.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView)
        }
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(bnScaleFit(4))
            make.centerX.equalToSuperview()
            make.width.equalTo(24)
            make.height.equalTo(6)
        }
        if let exchange = QPHomePageManager.sharedInstance.exchange {
            dataManager.currentExchange = exchange
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.contentSize = CGSize(width: kScreenW * 2.0, height: 0)
        }
    }
    
    private func initData() {
        dataManager.requestSuccessBlock = { [weak self] in
            guard let self = self else { return }
            self.hadRequestedFail = false
            self.collectionView.reloadData()
        }
        dataManager.requestfailureBlock = { [weak self] error in
            guard let self = self else { return }
            self.hadRequestedFail = self.dataList.count <= 0
            self.collectionView.reloadData()
        }
        dataManager.socketSnaptDataBlock = { [weak self] index in
            guard let self = self else { return }

            /// 对屏幕内的cell进行刷新
            let curRow = IndexPath(row: index, section: 0)
            if self.collectionView.indexPathsForVisibleItems.contains(curRow) {
                if let cell = self.collectionView.cellForItem(at: curRow) as? QUHomePreferredCompanyCell,
                    index < self.dataList.count {
                    cell.updateUI(model: self.dataList[index])
                }
            }
        }
        dataManager.socketIndexDataBlock = { [weak self] indexType, exchange, msg in
            guard let self = self else { return }
            if exchange == .HK {
                self.hkMarketIndexView.updateUI(with: indexType, msg: msg)
            } else if exchange == .US {
                self.usMarketIndexView.updateUI(with: indexType, msg: msg)
            }
        }
    }
    
    @objc private func detailMoreClick() {
        QUFlutterHelper.shared.jumpToFlutterController(.companyList)
    }
    
    private func followStock(model: QUHomePreferredCompanyCellModel, cell: QUHomePreferredCompanyCell) {
        guard let exchange = model.exchange, let stockCode = model.stockCode else { return }
        if let module = BNQuoteMainManager.shared.userOpenService(), !module.isLogin() {
            let topVc = BNNavigationHelper.findVisibleViewController()
            module.showLoginVc(toVc: topVc)
            return
        }
        cell.showFollowAnimation()
        var editType: StockOptionEditType = .insert
        if model.hasFollow == true {
            editType = .delete
        }
        model.hasFollow = !(model.hasFollow == true)
        QUWatchListCollectHelper.stockOptionEdit(type: editType, exchange: exchange.rawValue, stockCode: stockCode, isShowToast: true) {
            cell.hideFollowAnimation()
            cell.followButtonToggle()
        } failure: { result in
            cell.hideFollowAnimation()
        }
    }
}

extension QUHomePreferredCompanyController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QUHomePreferredCompanyCell", for: indexPath) as? QUHomePreferredCompanyCell else {
            return UICollectionViewCell()
        }
        if indexPath.row < dataList.count {
            cell.updateUI(model: dataList[indexPath.row])
        } else {
            cell.updateEmptyUI()
        }
        cell.followStockBlock = { [weak self] model, cell in
            guard let self = self else { return }
            self.followStock(model: model, cell: cell)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hadRequestedFail {
            return 6
        } else {
            return dataList.count
        }
    }
    
}

extension QUHomePreferredCompanyController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.row < dataList.count {
            let item = dataList[indexPath.row]
            let stockCode = item.stockCode ?? ""
            let exchange = item.exchange ?? .HK
            BNQuoteJumpHelper.jumpStockDetailVc(exchange: exchange, code: stockCode, categoryType: .mainBoard)
        }
    }
}

extension QUHomePreferredCompanyController {
    
    /// 请求精选公司列表
    private func fetchPreferredCompanyList() {
        dataManager.fetchHomeDiscoverCompanyList(exchange: .HK)
        dataManager.fetchHomeDiscoverCompanyList(exchange: .US)
    }
    
}

extension QUHomePreferredCompanyController: QUHomeMarketIndexViewDelegate {
    
    func didSelectIndex(view: QUHomeMarketIndexView, with indexType: QUMarketIndexType, exchange: ExchangeType) {
        let subFix = exchange == .US ? "" : ".IDX"
        let code = indexType.caseTitle + subFix
        if let stockItem = BNDBStockItem.queryStockItem(exchange.rawValue, code: code), let categoryType = stockItem.categoryType {
            BNQuoteJumpHelper.jumpStockDetailVc(exchange: exchange, code: code, categoryType: CategoryType(rawValue: categoryType) ?? .mainBoard)
        }
    }
}


extension QUHomePreferredCompanyController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            let exchange = ExchangeType(rawValue: page + 1) ?? .HK
            if dataManager.currentExchange != exchange {
                dataManager.currentExchange = exchange
                self.collectionView.reloadData()
                self.collectionView.contentOffset = .zero
            }
            pageControl.currentPage = page
        }
    }
    
}

