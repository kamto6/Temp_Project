//
//  QUHomeChoicenceChangeCellModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation
import UIKit
import BNUMain


struct QUHomeChoicenceChangeCellModel {

    var stockName: String?
    var stockCode: String?
    var exchangeIcon: UIImage?
    var rfRatio: String?
    var changeValue: String?
    var exchange: ExchangeType?
    var monitorName: String?
    var tradeTime: String?
    /// 涨跌类型
    var direction: StockRiseFallType?
    /// 时段描述
    var timeTypeDesc: String?
    
    enum MonitorType: Int {
        case rfRatio = 1
        case price = 2
        case turnover = 3
        case volume = 4
    }
    
    init(model: QUHomeChoicenceChangeModel) {
        if let value = model.exchange {
            self.exchange = ExchangeType(rawValue: value) ?? .unKnow
        } else {
            self.exchange = .unKnow
        }
        self.exchangeIcon = exchange?.image
        if let rfRatio = model.rfRatio {
            self.rfRatio = MPMarketDataHelper.getUpdownRate(value: rfRatio)
        } else {
            self.rfRatio = "--"
        }
        self.stockCode = model.stockCode
        if let stockCode = stockCode, let exchange = exchange, let stockItem: BNStockItem = BNDBStockItem.queryStockItem(exchange.rawValue, code: stockCode) {
            self.stockName = stockItem.getName()
        } else {
            self.stockName = model.stockName
        }
        // 触发内容 1-涨跌幅 2-价格 3-成交额 4-成交量；1的单位是10^5，2，3是10^4，4是真实数据
        let monitorTarget = model.monitorTarget ?? 0
        let monitorType = MonitorType(rawValue: monitorTarget)
        if let threshold = model.threshold, let monitorType = monitorType {
            if monitorType == .rfRatio {
                self.changeValue = MPMarketDataHelper.getUpdownRate(value: threshold, divisor: MPThousand)
            } else if monitorType == .price, let exchange = exchange {
                self.changeValue = MPMarketDataHelper.getStockPriceWithValue(value: threshold, exchange: exchange, divisor: MPTenThousand)
            } else if monitorType == .turnover {
                var volume = Double(threshold) / MPTenThousand
                self.changeValue = volume.toSpecialString(digits: 2)
            } else if monitorType == .volume {
                var volume = Double(threshold)
                self.changeValue = volume.toSpecialString(digits: 2) + NSLocalizedString("股", comment: "")
            } else {
                self.changeValue = "--"
            }
        } else {
            self.changeValue = "--"
        }
        self.monitorName = model.monitorName
        self.tradeTime = model.tradeTime
        let directionType = model.direction ?? 0
        /// 涨或跌 1-涨 2-跌 3-平
        if directionType == 1 {
            direction = .rise
        } else if directionType == 2 {
            direction = .fall
        } else {
            direction = .flat
        }
        timeTypeDesc = model.timeTypeDesc
    }
    
    func riseFallColor() -> UIColor {
        return MPMarketDataHelper.getPriceTextColor(type: direction ?? .flat, zeroColor: Quote_Gray2)
    }
    
}
