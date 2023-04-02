//
//  QUHomeFollowListModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation

struct QUHomeFollowListResult: BNCodable {
    var list: [QUHomeFollowListModel]?
}

struct QUHomeFollowListModel: BNCodable, Encodable, Decodable {
    
    /// 是否持仓
    var hasPosition: Int?
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
