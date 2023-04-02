//
//  QUHomeHotStockOrderModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation

struct QUHomeHotStockOrderResult: BNCodable, Encodable, Decodable {

    var list: [QUHomeHotStockOrderModel]?
}


struct QUHomeHotStockOrderModel: BNCodable, Encodable, Decodable {
    
    /// 市场类型
    var exchange: Int?
    /// 简介
    var introduction: String?
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
    var relatedRfRatio: Int?
    /// 股票名称
    var relatedStockName: String?
    /// 卡片底部色值
    var footColor: String?
    /// 卡片顶部色值
    var headColor: String?
    
}
