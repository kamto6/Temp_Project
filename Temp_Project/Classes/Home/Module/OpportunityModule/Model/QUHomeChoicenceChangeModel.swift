//
//  QUHomeChoicenceChangeModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/16.
//

import Foundation

struct QUHomeChoicenceChangeResult: BNCodable, Encodable, Decodable {
    
    var list: [QUHomeChoicenceChangeModel]?
}

struct QUHomeChoicenceChangeModel: BNCodable, Encodable, Decodable {
    
    /// 市场类型
    var exchange: Int?
    /// 最新价
    var last: Int?
    /// 规则名称
    var monitorName: String?
    /// 触发规则
    var monitorTarget: Int?
    /// 触发类型
    var monitorType: Int?
    /// 涨跌幅
    var rfRatio: Int?
    /// 涨跌额
    var riseFall: Int?
    /// 是否涨跌
    var direction: Int?
    /// 股票代码
    var stockCode: String?
    /// 股票名称
    var stockName: String?
    /// 阈值
    var threshold: Int?
    /// 时间
    var tradeTime: String?
    /// 时段描述
    var timeTypeDesc: String?
    
}
