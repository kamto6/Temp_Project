//
//  QUHomeHotDealModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation

struct QUHomeHotDealResult: BNCodable, Encodable, Decodable {
    
    var list: [QUHomeHotDealModel]?
}

struct QUHomeHotDealModel: BNCodable, Encodable, Decodable {
    
    /// 市场类型
    var exchange: Int?
    /// 最新价
    var last: Int?
    /// 涨跌幅
    var rfRatio: Int?
    /// 涨跌额
    var riseFall: Int?
    /// 股票代码
    var stockCode: String?
    /// 股票名称
    var stockName: String?
    
}
