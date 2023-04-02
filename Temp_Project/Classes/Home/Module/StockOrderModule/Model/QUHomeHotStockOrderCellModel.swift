//
//  QUHomeHotStockOrderCellModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation
import BNPAPI

struct QUHomeHotStockOrderCellModel {
    
    /// 市场类型
    var exchange: ExchangeType?
    /// 股票数量
    var orderCount: Int?
    /// 股单编号
    var orderId: Int?
    /// 股单名称
    var orderName: String?
    /// 股单图片
    var pictureURL: String?
    /// 代表股票
    var relatedStockCode: String?
    /// 涨跌幅
    var relatedRfRatio: String?
    /// 股票名称
    var relatedStockName: String?
    /// 涨跌类型
    var direction: StockRiseFallType?
    /// 卡片底部色值
    var footColor: String?
    /// 卡片顶部色值
    var headColor: String?
    
    init(model: QUHomeHotStockOrderModel) {
        if let value = model.exchange {
            self.exchange = ExchangeType(rawValue: value) ?? .unKnow
        } else {
            self.exchange = .unKnow
        }
        self.orderCount = model.orderCount
        self.orderName = model.orderName
        self.orderId = model.orderId
        self.pictureURL = model.pictureURL
        if let rfRatio = model.relatedRfRatio {
            self.relatedRfRatio = MPMarketDataHelper.getUpdownRate(value: rfRatio)
        } else {
            self.relatedRfRatio = "--"
        }
        
        self.relatedStockCode = model.relatedStockCode
        if let stockCode = relatedStockCode, let exchange = exchange, let stockItem: BNStockItem = BNDBStockItem.queryStockItem(exchange.rawValue, code: stockCode) {
            self.relatedStockName = stockItem.getName()
        } else {
            self.relatedStockName = model.relatedStockName
        }
        direction = MPMarketDataHelper.getRiseFallType(value: model.relatedRfRatio ?? 0)
        headColor = model.headColor
        footColor = model.footColor
    }

    func riseFallColor() -> UIColor {
        return MPMarketDataHelper.getPriceTextColor(type: direction ?? .flat)
    }
    
}
