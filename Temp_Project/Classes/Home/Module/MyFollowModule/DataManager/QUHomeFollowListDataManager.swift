//
//  QUHomeFollowListDataManager.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation
import BNPAPI
import BNUMain

class QUHomeFollowListDataManager: NSObject {
    
    private var followList: [QUHomeFollowListCellModel]? {
        didSet {
            stockCodeMap.removeAll()
            guard let list = followList else { return }
            for item in list {
                guard let exchange = item.exchange, let stockCode = item.stockCode else { continue }
                var codes = stockCodeMap[exchange] ?? []
                codes.append(stockCode)
                stockCodeMap[exchange] = codes
            }
            subcriptStocks()
        }
    }
    
    /// 火花图数据
    private var mlineDataMap: [String: [KlineMinData]] = [:]
    
    /// 订阅codes数据
    private var stockCodeMap: [ExchangeType: [String]] = [:]
    /// 我的关注交易状态
    private var stockTradeStatusMap = [String: QUTradeStatusType]()
    
    private let disposeBag = DisposeBag()
    private let quotesAPIClient = QUQuotesAPIClient()
    /// 最多展示的item个数
    let maxShowCount: Int = 20
    
    var requestfailureBlock: ((_ error: BNHTTPError) -> Void)?
    var requestSuccessBlock: (() -> Void)?
    var socketQuoteSnaptDataBlock: ((_ index: Int) -> Void)?
    var socketQuoteSparkDataBlock: ((_ index: Int) -> Void)?
    
    func fetchHomeDiscoverFollowList(isLoadCache: Bool = true) {
        QPHomeRequestManager.fetchHomeDiscoverFollowList()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .failure(let error):
                    self.requestfailureBlock?(error)
                case .success(let response):
                    self.followList?.removeAll()
                    if var list = response.list {
                        if list.count > self.maxShowCount {
                            list = Array(list[0 ... self.maxShowCount - 1])
                        }
                        self.followList = list.map { return QUHomeFollowListCellModel(model: $0) }
                        BNUserDefaultsStorage.setStructArray(list, forKey: QUUserStorageKey.discoverFollowList.appendUserId())
                    }
                    self.requestSuccessBlock?()
                }
            }).disposed(by: disposeBag)
    }
    
    /// 缓存
    func loadCacheData() {
        if BNQuoteMainManager.shared.isLogin(){
            let list = BNUserDefaultsStorage.structArrayData(QUHomeFollowListModel.self, forKey: QUUserStorageKey.discoverFollowList.appendUserId())
            self.followList = list.map { return QUHomeFollowListCellModel(model: $0) }
        }
        requestSuccessBlock?()
    }
    
    /// 订阅数据
    func subcriptStocks() {
        for (exchange, codes) in stockCodeMap {
            quotesAPIClient.subscribe(delegate: self, exchange: exchange, codes: codes, bizType: 301) { response in
                QuoteLogger.debug( "我的关注订阅成功")
            } failure: { _ in
                
            }
        }
        stockTradeStatusMap.removeAll()
        fetchStockMlines()
    }
    
    /// 取消订阅数据
    func unSubcriptStocks() {
        for (exchange, codes) in stockCodeMap {
            quotesAPIClient.unSubscribe(delegate: self, exchange: exchange, codes: codes, bizType: 301) { response in
                QuoteLogger.debug( "我的关注取消订阅成功")
            } failure: { _ in
                
            }
        }
    }
    
    /// 请求火花图
    func fetchStockMlines() {
        guard let list = followList else { return }
        let stockCodes = list.compactMap { $0.stockCode }
        for code in stockCodes {
            if let index = list.firstIndex(where: { $0.stockCode == code }) {
                let item = list[index]
                guard let exchange = item.exchange else { continue }
                fetchStockMline(stockCode: code, exchange: exchange, index: index)
            }
        }
    }
    
    private func fetchStockMline(stockCode: String, exchange: ExchangeType, index: Int) {
        quotesAPIClient.queryKLineMinMessage(delegate: self, exchange: exchange, code: stockCode, subscribe: true) { [weak self] response in
            guard let self = self else { return }
            var mlines = response?.data ?? []
            let count = BNSection.getXAxisMLinePlotCount(with: exchange)
            if mlines.count > count {
                mlines = Array(mlines[0 ... count - 1])
            }
            self.mlineDataMap[stockCode] = mlines
            self.socketQuoteSparkDataBlock?(index)
            QuoteLogger.info(business: "行情", message: "我的关注火花图请求成功: code: \(stockCode), count: \(mlines.count) ")
        } failure: { [weak self]  error in
            guard let self = self else { return }
            self.socketQuoteSparkDataBlock?(index)
            // 打印
            QuoteLogger.info(business: "行情", message: "我的关注火花图请求失败: code: \(stockCode)")
//            QuoteLogger.debug("我的关注火花图 \(stockCode), 全量请求失败，")
        }
    }
    
    
    func getHomeDicoverFollowList() -> [QUHomeFollowListCellModel] {
        return followList ?? []
    }
    
    func getSparkData(with stockCode: String?) -> [KlineMinData] {
        guard let stockCode = stockCode else {
            return []
        }
        return mlineDataMap[stockCode] ?? []
    }
    
}

extension QUHomeFollowListDataManager: BNQuotesManagerDelegate {
    
    // 301:基础报价信息-QuoteBasicPrice
    func didReceive(msg: QuoteBasicPrice) {
        guard let list = followList else { return }
        let msgExchange = ExchangeType(rawValue: Int(msg.commonInfo.exchange))
        if let index = list.firstIndex(where: { $0.stockCode == msg.commonInfo.instrCode && $0.exchange == msgExchange }) {
            /// 更新现价和涨跌幅
            let item = list[index]
            item.last = MPMarketDataHelper.getStockPriceWithValue(value: Double(msg.last), exchange: item.exchange ?? .unKnow)
            item.rfRatio = MPMarketDataHelper.getUpdownRate(value: Double(msg.rFRatio))
            item.direction = MPMarketDataHelper.getRiseFallType(value: Double(msg.rFRatio))
            socketQuoteSnaptDataBlock?(index)
            
            /// 更新火花图
            var canRefresh = true
            if msgExchange == .HK, let tradeStatus = QUTradeStatusType(rawValue: Int(msg.tradeStatus)), tradeStatus != .inTransaction {
                /// 港股只更新盘中的火花图
                canRefresh = false
            }
            if canRefresh, let stockCode = item.stockCode {
                let lineDatas = mlineDataMap[stockCode] ?? []
                let needUpdate = QUMLineDataHelper.updateLines(with: lineDatas, basicPrice: msg) { data in
                    mlineDataMap[stockCode] = data
                }
                if needUpdate {
                    socketQuoteSparkDataBlock?(index)
                }
            }
            let tradeStatus = QUTradeStatusType(rawValue: Int(msg.tradeStatus)) ?? .unknown
            updateTradeStatusType(tradeStatus: tradeStatus, stockCode: msg.commonInfo.instrCode, exchange: msgExchange, index: index)
        }
    }
    
    private func updateTradeStatusType(tradeStatus: QUTradeStatusType, stockCode: String, exchange: ExchangeType?, index: Int) {
        guard let exchange = exchange else { return }
        if let oldStatusType = stockTradeStatusMap[stockCode], oldStatusType != tradeStatus {
            // 状态不一致，则先更新状态，再请求全量火花图数据
            stockTradeStatusMap[stockCode] = tradeStatus
            mlineDataMap[stockCode] = []
            fetchStockMline(stockCode: stockCode, exchange: exchange, index: index)
            QuoteLogger.info(business: "行情", message: "发现首页交易状态发生改变，当前为: \(tradeStatus.rawValue)")
        } else if let oldStatusType = stockTradeStatusMap[stockCode], oldStatusType == .liquidation, (mlineDataMap[stockCode]?.count ?? 0) > 0 {
            /// 防止清盘中，但火花图数据还未清空的场景
            mlineDataMap[stockCode] = []
            fetchStockMline(stockCode: stockCode, exchange: exchange, index: index)
        } else {
            stockTradeStatusMap[stockCode] = tradeStatus
        }
    }
}
