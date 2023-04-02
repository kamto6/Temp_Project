//
//  QUHomePreferredCompanyCellModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/15.
//

import Foundation
import UIKit
import BNUMain

class QUHomePreferredCompanyCellModel {
    
    var stockName: String?
    var stockCode: String?
    var hasFollow: Bool?
    var rfRatio: String?
    var exchange: ExchangeType?
    var logoURl: String?
    var direction: StockRiseFallType?
    var enName: String?
    var isDelay: Bool = true
    
    init(model: QUHomePreferredCompanyModel) {
        if let value = model.exchange {
            self.exchange = ExchangeType(rawValue: value) ?? .unKnow
        } else {
            self.exchange = .unKnow
        }
        if let rfRatio = model.rfRatio {
            self.rfRatio = MPMarketDataHelper.getUpdownRate(value: rfRatio)
        } else {
            self.rfRatio = "--"
        }
        if let hasFollow = model.hasFollow {
            self.hasFollow = hasFollow == 1
        } else {
            self.hasFollow = nil
        }
        self.stockCode = model.stockCode
        if let stockCode = stockCode, let exchange = exchange, let stockItem: BNStockItem = BNDBStockItem.queryStockItem(exchange.rawValue, code: stockCode) {
            self.stockName = stockItem.getName()
        } else {
            self.stockName = model.stockName
        }
        logoURl = model.logoURL
        enName = model.enName
        direction = MPMarketDataHelper.getRiseFallType(value: model.rfRatio ?? 0)
        if let exchange = exchange {
            isDelay = BNQuoteMainManager.shared.isUserMarketLevelTwo(exchange: exchange) == false
        } else {
            isDelay = true
        }
    }
    
    func riseFallColor() -> UIColor {
        return MPMarketDataHelper.getPriceTextColor(type: direction ?? .flat, zeroColor: Quote_Gray2)
    }
    
}
