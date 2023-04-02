//
//  QUHomeFollowListCellModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation
import UIKit
import BNUMain

class QUHomeFollowListCellModel {

    var stockName: String?
    var stockCode: String?
    var hasPosition: Bool?
    var last: String?
    var rfRatio: String?
    var exchange: ExchangeType?
    var direction: StockRiseFallType?
    var isDelay: Bool = true
    
    init(model: QUHomeFollowListModel) {
        if let value = model.exchange {
            self.exchange = ExchangeType(rawValue: value) ?? .unKnow
        } else {
            self.exchange = .unKnow
        }
        if let last = model.last, let exchange = exchange {
            self.last = MPMarketDataHelper.getStockPriceWithValue(value: last, exchange: exchange)
        } else {
            self.last = "--"
        }
        if let rfRatio = model.rfRatio {
            self.rfRatio = MPMarketDataHelper.getUpdownRate(value: rfRatio)
        } else {
            self.rfRatio = "--"
        }
        if let hasPosition = model.hasPosition {
            self.hasPosition = hasPosition == 1
        } else {
            self.hasPosition = nil
        }
        self.stockCode = model.stockCode
        if let stockCode = stockCode, let exchange = exchange, let stockItem: BNStockItem = BNDBStockItem.queryStockItem(exchange.rawValue, code: stockCode) {
            self.stockName = stockItem.getName()
        } else {
            self.stockName = model.stockName
        }
        direction = MPMarketDataHelper.getRiseFallType(value: model.rfRatio ?? 0)
        if let exchange = exchange {
            isDelay = BNQuoteMainManager.shared.isUserMarketLevelTwo(exchange: exchange) == false
        } else {
            isDelay = true
        }
    }
    
    func riseFallColor() -> UIColor {
        return MPMarketDataHelper.getPriceTextColor(type: direction ?? .flat)
    }
    
}
