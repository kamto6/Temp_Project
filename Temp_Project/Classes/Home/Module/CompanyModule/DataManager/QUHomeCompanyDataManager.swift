//
//  QUHomeCompanyDataManager.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/15.
//

import Foundation
import BNPAPI
import BNStorageKit
import BNUMain

class QUHomeCompanyDataManager: NSObject {
    
    /// Public
    /// 指数
    var indexTypeMap: [ExchangeType: [QUMarketIndexType]] {
        return [.US: [.DIA, .QQQ, .SPY], .HK: [.HSI, .HSTECH, .CCI]]
    }
    /// 当前处于什么交易市场
    var currentExchange: ExchangeType = QPHomePageManager.sharedInstance.exchange ?? .HK
    
    /// Private
    /// 精选公司数据源
    private var dataMap = [ExchangeType: [QUHomePreferredCompanyCellModel]]()
    /// 股票代码
    private var stockCodeMap: [ExchangeType: [String]] = [:]
    
    private let disposeBag = DisposeBag()
    private let quotesAPIClient = QUQuotesAPIClient()
    private var subcriptIndexSuccess = false
    
    var requestfailureBlock: ((_ error: BNHTTPError) -> Void)?
    var requestSuccessBlock: (() -> Void)?
    var socketSnaptDataBlock: ((_ index: Int) -> Void)?
    var socketIndexDataBlock: ((QUMarketIndexType, ExchangeType, QuoteBasicPrice) -> Void)?

    func fetchHomeDiscoverCompanyList(exchange: ExchangeType) {
        QPHomeRequestManager.fetchHomeDiscoverCompanyList(exchange: exchange)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .failure(let error):
                    self.requestfailureBlock?(error)
                case .success(let response):
                    if let list = response.list {
                        self.dataMap[exchange] = list.map { return QUHomePreferredCompanyCellModel(model: $0) }
                        self.unSubcriptCompanyStocks(exchange: exchange)
                        for item in list {
                            guard let curExchange = ExchangeType(rawValue: item.exchange ?? 0) , let stockCode = item.stockCode else { continue }
                            var codes = self.stockCodeMap[curExchange] ?? []
                            codes.append(stockCode)
                            self.stockCodeMap[curExchange] = codes
                        }
                        self.subcriptCompanyStocks(exchange: exchange)
                    }
                    self.requestSuccessBlock?()
                    if exchange == .HK {
                        BNUserDefaultsStorage.setStruct(response, forKey: QUUserStorageKey.discoverHKCompanyList.appendUserId())
                    } else if exchange == .US {
                        BNUserDefaultsStorage.setStruct(response, forKey: QUUserStorageKey.discoverUSCompanyList.appendUserId())
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    /// 缓存
    func loadCacheData() {
        let hkResponse = BNUserDefaultsStorage.structData(forKey: QUUserStorageKey.discoverHKCompanyList.appendUserId(), type: QUHomePreferredCompanyResult.self)
        let usResponse = BNUserDefaultsStorage.structData(forKey: QUUserStorageKey.discoverUSCompanyList.appendUserId(), type: QUHomePreferredCompanyResult.self)
        if let list = hkResponse?.list {
            dataMap[.HK] = list.map { return QUHomePreferredCompanyCellModel(model: $0) }
        }
        if let list = usResponse?.list {
            dataMap[.US] = list.map { return QUHomePreferredCompanyCellModel(model: $0) }
        }
    }
    
    /// 根据市场订阅数据
    private func subcriptCompanyStocks(exchange: ExchangeType) {
        if let codes = stockCodeMap[exchange] {
            /// 订阅精选公司
            quotesAPIClient.subscribe(delegate: self, exchange: exchange, codes: codes, bizType: 301) { response in
                QuoteLogger.debug("精选公司订阅成功")
            } failure: { _ in
                
            }
        }
    }
    
    /// 根据市场取消订阅数据
    private func unSubcriptCompanyStocks(exchange: ExchangeType) {
        if let codes = stockCodeMap[exchange] {
            /// 取消订阅精选公司
            quotesAPIClient.unSubscribe(delegate: self, exchange: exchange, codes: codes, bizType: 301) { response in
                QuoteLogger.debug("精选公司取消订阅成功")
            } failure: { _ in
                
            }
        }
    }

    /// 订阅指数
    private func subcriptIndexStocks() {
        /// 订阅指数
        for (exchange, _) in indexTypeMap {
            let subscriptCodes = getSubscriptCodes(with: exchange)
            quotesAPIClient.subscribe(delegate: self, exchange: exchange, codes: subscriptCodes, bizType: 301) { response in
                QuoteLogger.debug("discover index subcribe status: code=\(String(describing: response?.retResult.retCode)),msg=\(String(describing: response?.retResult.retMsg))")
            } failure: { _ in
                QuoteLogger.debug("discover index subcribe status fail")
            }
        }
    }
    
    /// 取消订阅指数
    private func unSubcriptIndexStocks() {
        /// 订阅指数
        for (exchange, _) in indexTypeMap {
            let subscriptCodes = getSubscriptCodes(with: exchange)
            quotesAPIClient.unSubscribe(delegate: self, exchange: exchange, codes: subscriptCodes, bizType: 301) { response in
                QuoteLogger.debug("index unsubcribe status: code=\(String(describing: response?.retResult.retCode)),msg=\(String(describing: response?.retResult.retMsg))")
            } failure: { _ in
            }
        }
    }
    
    /// 取消全部订阅
    func unSubcriptAllStocks() {
        for (exchange, _) in stockCodeMap {
            unSubcriptCompanyStocks(exchange: exchange)
        }
        unSubcriptIndexStocks()
    }
    
    /// 取消全部订阅
    func subcriptAllStocks() {
        for (exchange, _) in stockCodeMap {
            subcriptCompanyStocks(exchange: exchange)
        }
        subcriptIndexStocks()
    }
    
    
    private func getSubscriptCodes(with exchange: ExchangeType) -> [String] {
        /// 港股是指数，后面需要加.IDX
        let subFix = exchange == .US ? "" : ".IDX"
        let list = indexTypeMap[exchange] ?? []
        return list.map { return $0.caseTitle + subFix }
    }

    func getHomeDicoverCompanyList() -> [QUHomePreferredCompanyCellModel] {
        return dataMap[currentExchange] ?? []
    }
    
    /// 更新收藏状态
    func updateCollectState(stockModels: [QUStockModel], hasFollow: Bool) {
        var isNeedReload = false
        var currentCollectCodes = [String]()
        for item in stockModels {
            let key = item.exchange.convertToString() + "_" + item.stockCode
            currentCollectCodes.append(key)
        }
        
        for (_, list) in dataMap {
            for item in list {
                let key = (item.exchange ?? .unKnow).convertToString() + "_" + (item.stockCode ?? "")
                if currentCollectCodes.contains(key) {
                    item.hasFollow = hasFollow
                    if !isNeedReload {
                        isNeedReload = true
                    }
                }
            }
        }
        if isNeedReload {
            requestSuccessBlock?()
        }
    }
}

extension QUHomeCompanyDataManager: BNQuotesManagerDelegate {
    
    // 301:基础报价信息-QuoteBasicPrice
    func didReceive(msg: QuoteBasicPrice) {
        guard let list = dataMap[currentExchange] else { return }
        let msgExchange = ExchangeType(rawValue: Int(msg.commonInfo.exchange))
        if let index = list.firstIndex(where: { $0.stockCode == msg.commonInfo.instrCode && $0.exchange == msgExchange }) {
            let item = list[index]
            item.rfRatio = MPMarketDataHelper.getUpdownRate(value: Double(msg.rFRatio))
            item.direction = MPMarketDataHelper.getRiseFallType(value: Double(msg.rFRatio))
            socketSnaptDataBlock?(index)
        }
        if let exchange = msgExchange, let indexType = QUMarketIndexType.getIndexType(with: msg.commonInfo.instrCode), (indexTypeMap[exchange] ?? []).contains(indexType) {
            socketIndexDataBlock?(indexType, exchange, msg)
        }
    }
}

