//
//  QPHomePageManager.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/19.
//

import Foundation
import BNHttpKit
import BNPAPI

class QPHomePageManager {
    
    static let sharedInstance = QPHomePageManager()
    var exchange: ExchangeType?
    var pageIndexModel: QUHomePageIndexModel?
    
    private let disposeBag = DisposeBag()
    
    init() {
        if let value = BNUserDefaultsStorage.value(forKey: QUStorageKey.discoverExchange.rawValue) as? Int, let exchange = ExchangeType(rawValue: value) {
            self.exchange = exchange
        }
    }
       
    /// 首页发现获取当前交易市场
    func fetchCurrentExchange() {
        QPHomeRequestManager.fetchHomeExchange().subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现获取当前交易市场失败，\(error.localizedDescription)")
            case .success(let response):
                self.exchange = ExchangeType(rawValue: response.exchange ?? 0)
                BNUserDefaultsStorage.set(response.exchange ?? 0, forKey: QUStorageKey.discoverExchange.rawValue)
                NotificationCenter.default.post(name: Notification.Name(rawValue: nkDidGetCurrentExchangeNoti), object: nil)
            }
        }).disposed(by: disposeBag)
    }
    
    /// 首页发现获取首页模块排序显隐列表
    func fetchHomeRankList(sucessBlock: @escaping () -> Void) {
        QPHomeRequestManager.fetchHomePageIndex().subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现获取索引失败，\(error.localizedDescription)")
            case .success(let response):
                self.pageIndexModel = response
                sucessBlock()
                BNUserDefaultsStorage.setStruct(response, forKey: QUUserStorageKey.discoverRankList.rawValue)
            }
        }).disposed(by: disposeBag)
    }
}
