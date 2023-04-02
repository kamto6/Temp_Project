//
//  QUHomeChoicenessChangeController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation
import UIKit
import BNUMain

class QUHomeChoicenessChangeController: BNBaseViewController {
    
    // MARK: - Properties
    
    private lazy var bgImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_choicechange_bg")
        return view
    }()
    
    private lazy var titleLogo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_choicechange_logo")
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
        view.register(QUHomeChoicenceChangeCell.self, forCellReuseIdentifier: "QUHomeChoicenceChangeCell")
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
            self.fetchHomeDiscoverChoicenceChangeList()
        }
        return view
    }()
    
    private lazy var noPermissionView: QUMarketNoPermissionView = {
        let view = QUMarketNoPermissionView(frame: .zero, noDataText: "", imageTopMargin: bnScaleFit(40), imageBottomMargin: bnScaleFit(8), imageFixedWidth: 120)
        view.backgroundColor = .clear
        view.upgradeBlock = { [weak self] in
            guard let self = self else { return }
            BNQuoteJumpHelper.jumpMarketLevelTwoUpgradeVc()
        }
        return view
    }()
    
    private let maxShowCount: Int = 5
    private var dataList: [QUHomeChoicenceChangeCellModel] = []
    
    // MARK: - Init
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotifications()
        loadCacheData()
        fetchHomeDiscoverChoicenceChangeList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Publics
    
    func headerRefresh() {
        fetchHomeDiscoverChoicenceChangeList()
    }
    
    func colorChanged() {
        tableView.reloadData()
    }
    
}

extension QUHomeChoicenessChangeController {
    
    // MARK: - Notifications
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnect), name: NSNotification.Name(rawValue: nkUpdateUserMarketAuthLevel), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentExchange(_:)), name: NSNotification.Name(rawValue: nkDidGetCurrentExchangeNoti), object: nil)
    }
    
    @objc private func socketConnect() {
        fetchHomeDiscoverChoicenceChangeList()
        updateCurrentExchange()
    }
    
    @objc private func updateCurrentExchange(_ noti: Notification? = nil) {
        if let item = view.subviews.filter({ ($0 is QUMarketNoPermissionView) }).first {
            if let target = item as? QUMarketNoPermissionView {
                updateNoPermission(with: target)
            }
        }
    }
    
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
            make.top.equalToSuperview().offset(bnScaleFit(56))
        }
    }
    
    @objc private func detailMoreClick() {
        if let module = ServiceManager.sharedInstance.moduleByService(service: UserOpenService.self) as? UserOpenService, !module.isLogin() {
            module.showLoginVc(toVc: self)
            return
        }
        var exchange: ExchangeType?
        if dataList.count > 0 {
            exchange = dataList[0].exchange
        } else {
            exchange = QPHomePageManager.sharedInstance.exchange ?? .HK
        }
        guard let exchange = exchange else { return }
        let tabId = exchange.rawValue
        var hkPlaceMap = [String: String]()
        var usPlaceMap = [String: String]()
        if let module = ServiceManager.sharedInstance.moduleByService(service: UserOpenService.self) as? UserOpenService {
            let hkModel = module.getPaperWorkModel(placeType: .featuredTransactions, exchange: ExchangeType.HK.rawValue)
            hkPlaceMap = ["title": hkModel.title ?? "", "content": hkModel.content ?? "", "url": hkModel.url ?? ""]
            let usModel = module.getPaperWorkModel(placeType: .featuredTransactions, exchange: ExchangeType.US.rawValue)
            usPlaceMap = ["title": usModel.title ?? "", "content": usModel.content ?? "", "url": usModel.url ?? ""]
        }
        QUFlutterHelper.shared.jumpToFlutterController(.featuredTransactions, arguments: ["tabId": tabId, "hkPlace": hkPlaceMap, "usPlace": usPlaceMap])
    }
    
}

extension QUHomeChoicenessChangeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QUHomeChoicenceChangeCell", for: indexPath) as? QUHomeChoicenceChangeCell else {
            return UITableViewCell()
        }
        if indexPath.row < dataList.count {
            cell.updateUI(model: dataList[indexPath.row])
        } else {
            cell.updateEmaptyUI()
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

extension QUHomeChoicenessChangeController {
    
    /// 请求精选异动数据
    @objc private func fetchHomeDiscoverChoicenceChangeList() {
        if dataList.count <= 0 && isReachableToInternet() == false {
            showEmptyView(.LoadFailue)
            return
        }
        
        let exchange = QPHomePageManager.sharedInstance.exchange ?? .HK
        guard BNQuoteMainManager.shared.isUserMarketLevelTwo(exchange: exchange) else {
            showOrHideNoPermissionView(isShow: true)
            return
        }
        showOrHideNoPermissionView(isShow: false)
        
        QPHomeRequestManager.fetchHomeDiscoverChoicenceChangeList().subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现精选异动列表失败，\(error.localizedDescription)")
                if self.dataList.count < 0 {
                    self.showEmptyView(.LoadFailue)
                }
            case .success(let response):
                self.dataList.removeAll()
                if var list = response.list {
                    if list.count > self.maxShowCount {
                        list = Array(list[0 ... self.maxShowCount - 1])
                    }
                    self.dataList = list.map { return QUHomeChoicenceChangeCellModel(model: $0) }
                }
                self.tableView.reloadData()
                let type: BNEmptyDataType? = self.dataList.count <= 0 ? .NoData : nil
                self.showEmptyView(type)
                BNUserDefaultsStorage.setStruct(response, forKey: QUUserStorageKey.discoverChoiceChangeList.rawValue)
            }
        }).disposed(by: disposeBag)
    }
    
    /// 缓存
    private func loadCacheData() {
        let exchange = QPHomePageManager.sharedInstance.exchange ?? .HK
        guard BNQuoteMainManager.shared.isUserMarketLevelTwo(exchange: exchange) else {
            return
        }
        if let response = BNUserDefaultsStorage.structData(forKey: QUUserStorageKey.discoverChoiceChangeList.rawValue, type: QUHomeChoicenceChangeResult.self) {
            if var list = response.list {
                if list.count > maxShowCount {
                    list = Array(list[0 ... maxShowCount - 1])
                }
                dataList = list.map { return QUHomeChoicenceChangeCellModel(model: $0) }
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
        tableView.reloadData()
    }
    
    private func showOrHideNoPermissionView(isShow: Bool) {
        if isShow {
            if noPermissionView.superview == nil {
                view.addSubview(noPermissionView)
                noPermissionView.snp.makeConstraints { make in
                    make.edges.equalTo(tableView)
                }
                updateNoPermission(with: noPermissionView)
            }
        } else {
            if let item = view.subviews.filter({ ($0 is QUMarketNoPermissionView) }).first {
                item.removeFromSuperview()
            }
        }
        tableView.reloadData()
    }
    
    private func updateNoPermission(with view: QUMarketNoPermissionView) {
        let exchange = QPHomePageManager.sharedInstance.exchange ?? .HK
        guard let module = ServiceManager.sharedInstance.moduleByService(service: UserOpenService.self) as? UserOpenService else {
            return
        }
        let model = module.getPaperWorkModel(placeType: .featuredTransactions, exchange: exchange.rawValue)
        let noPermissionText = model.title?.replace("\\n", with: "\n")
        let noPermissionButtonText = model.content
        view.updateText(noPermissionText)
        view.updateButtonText(noPermissionButtonText)
    }
    
    private func numberOfSections() -> Int {
        if let _ = view.subviews.filter({ ($0 is QUMarketNoPermissionView) || ($0 is QUMarketNoDataView) || ($0 is QUMarketRequestFailView) }).first {
            return 0
        } else {
            return (dataList.count > 0) ? maxShowCount : 0
        }
    }
    
}
