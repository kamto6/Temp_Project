//
//  QUHomePreferredCompanyModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/15.
//

import Foundation

struct QUHomePreferredCompanyResult: BNCodable, Encodable, Decodable {
    var list: [QUHomePreferredCompanyModel]?
}

struct QUHomePreferredCompanyModel: BNCodable, Encodable, Decodable  {
    
    /// 英文名称
    var enName: String?
    /// 市场类型
    var exchange: Int?
    /// 是否关注 1是 2否
    var hasFollow: Int?
    /// 最新价
    var last: Int?
    /// logo
    var logoURL: String?
    /// 涨跌幅
    var rfRatio: Int?
    /// 涨跌额
    var riseFall: Int?
    /// 股票代码
    var stockCode: String?
    /// 股票名称
    var stockName: String?
    
}
