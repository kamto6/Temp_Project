//
//  QUHomeHotDealController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation
import UIKit
import BNStorageKit
import BNPAPI

class QUHomeHotDealController: BNBaseViewController {
    
    // MARK: - Properties
    
    private lazy var bgImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_hotdeal_bg")
        return view
    }()
    
    private lazy var titleLogo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_hotdeal_logo")
        return view
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

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.dataSource = self
        view.delegate = self
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.register(QUHomeHotDealCell.self, forCellReuseIdentifier: "QUHomeHotDealCell")
        view.estimatedSectionFooterHeight = 0
        view.estimatedRowHeight = 0
        view.estimatedSectionHeaderHeight = 0
        view.rowHeight = bnScaleFit(60)
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
        return view
    }()
    
    private lazy var emptyView: QUMarketNoDataView = {
        let view = QUMarketNoDataView(frame: .zero, noDataText: NSLocalizedString("暂无数据", comment: ""), imageTopMargin: bnScaleFit(40), imageBottomMargin: bnScaleFit(8), imageFixedWidth: bnScaleFit(120))
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var failView: QUMarketRequestFailView = {
        let view = QUMarketRequestFailView(frame: .zero, noDataText: NSLocalizedString("加载失败", comment: ""), imageTopMargin: bnScaleFit(40), imageBottomMargin: bnScaleFit(8), imageFixedWidth: bnScaleFit(120), axis: .horizontal)
        view.backgroundColor = .clear
        view.refreshDataBlock = { [weak self] in
            guard let self = self else { return }
            self.fetchHomeDiscoverHotDealList()
        }
        return view
    }()
    
    private let maxShowCount: Int = 5
    private var dataList: [QUHomeHotDealCellModel] = []
    
    deinit {
        
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotifications()
        loadCacheData()
        fetchHomeDiscoverHotDealList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Publics
    
    func headerRefresh() {
        fetchHomeDiscoverHotDealList()
    }
    
    func colorChanged() {
        tableView.reloadData()
    }
    
}

extension QUHomeHotDealController {
    
    // MARK: - Notifications
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnect), name: NSNotification.Name(rawValue: nkUpdateUserMarketAuthLevel), object: nil)
    }
    
    @objc private func socketConnect() {
        fetchHomeDiscoverHotDealList()
    }
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        view.addSubview(bgImageView)
        view.addSubview(titleLogo)
        view.addSubview(detailButton)
        view.addSubview(tableView)
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLogo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(18))
            make.top.equalToSuperview().offset(bnScaleFit(18))
        }
        detailButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(18))
            make.centerY.equalTo(titleLogo)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(6))
            make.right.equalToSuperview().offset(-bnScaleFit(6))
            make.bottom.equalToSuperview().offset(-bnScaleFit(6))
            make.top.equalToSuperview().offset(bnScaleFit(55))
        }
        
    }
    
    @objc private func detailMoreClick() {
        var exchange = getCurrentExchange()
        if exchange == nil {
            exchange = QPHomePageManager.sharedInstance.exchange ?? .HK
        }
        guard let exchange = exchange else { return }
        let tabId = exchange.rawValue
        QUFlutterHelper.shared.jumpToFlutterController(.hotClinch, arguments: ["tabId": tabId])
    }
    
}

extension QUHomeHotDealController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QUHomeHotDealCell", for: indexPath) as? QUHomeHotDealCell else {
            return UITableViewCell()
        }
        if indexPath.row < dataList.count {
            cell.updateUI(model: dataList[indexPath.row], index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row < dataList.count {
            let item = dataList[indexPath.row]
            let stockCode = item.stockCode ?? ""
            let exchange = item.exchange ?? .HK
            BNQuoteJumpHelper.jumpStockDetailVc(exchange: exchange, code: stockCode, categoryType: .mainBoard)
        }
    }
    
}

extension QUHomeHotDealController {
    
    /// 请求成交热门数据
    private func fetchHomeDiscoverHotDealList() {
        if dataList.count <= 0 && isReachableToInternet() == false {
            showEmptyView(.LoadFailue)
        }
        QPHomeRequestManager.fetchHomeDiscoverHotDealList().subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现成交热门列表失败，\(error.localizedDescription)")
                if self.dataList.count <= 0 {
                    self.showEmptyView(.LoadFailue)
                }
                
            case .success(let response):
                self.dataList.removeAll()
                if var list = response.list {
                    if list.count > self.maxShowCount {
                        list = Array(list[0 ... self.maxShowCount - 1])
                    }
                    self.dataList = list.map { return QUHomeHotDealCellModel(model: $0) }
                }
                BNUserDefaultsStorage.setStruct(response, forKey: QUUserStorageKey.discoverHotDealList.rawValue)
                self.tableView.reloadData()
                let type: BNEmptyDataType? = self.dataList.count <= 0 ? .NoData : nil
                self.showEmptyView(type)
                let exchange = QPHomePageManager.sharedInstance.exchange
                if let currentExchange = self.getCurrentExchange(), currentExchange != exchange {
                    QPHomePageManager.sharedInstance.exchange = currentExchange
                    NotificationCenter.default.post(name: Notification.Name(rawValue: nkDidGetCurrentExchangeNoti), object: nil)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    /// 缓存
    private func loadCacheData() {
        if let response = BNUserDefaultsStorage.structData(forKey: QUUserStorageKey.discoverHotDealList.rawValue, type: QUHomeHotDealResult.self) {
            if var list = response.list {
                if list.count > maxShowCount {
                    list = Array(list[0 ... maxShowCount - 1])
                }
                dataList = list.map { return QUHomeHotDealCellModel(model: $0) }
            }
            tableView.reloadData()
        }
    }
    
    private func showEmptyView(_ type: BNEmptyDataType? = nil) {
        if type == .LoadFailue {
            if failView.superview == nil {
                view.addSubview(failView)
                failView.snp.makeConstraints { make in
                    make.edges.equalTo(tableView)
                }
            }
            if let item = view.subviews.filter({ ($0 is QUMarketNoDataView) }).first {
                item.removeFromSuperview()
            }
        } else if type == .NoData {
            if emptyView.superview == nil {
                view.addSubview(emptyView)
                emptyView.snp.makeConstraints { make in
                    make.edges.equalTo(tableView)
                }
            }
            if let item = view.subviews.filter({ ($0 is QUMarketRequestFailView) }).first {
                item.removeFromSuperview()
            }
        } else {
            if let item = view.subviews.filter({ ($0 is QUMarketRequestFailView) }).first {
                item.removeFromSuperview()
            }
            if let item = view.subviews.filter({ ($0 is QUMarketNoDataView) }).first {
                item.removeFromSuperview()
            }
        }
    }
    
    
    /// 获取当前列表的exchange
    private func getCurrentExchange() -> ExchangeType? {
        var exchange: ExchangeType?
        if dataList.count > 0 {
            exchange = dataList[0].exchange
        }
        return exchange
    }
    
}
