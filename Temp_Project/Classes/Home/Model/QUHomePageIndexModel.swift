//
//  QUHomePageIndexModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/31.
//

import Foundation

struct QUHomePageIndexModel: BNCodable, Encodable, Decodable {
    
    var list: [Int]?
    
    var typeList: [QUHomeComponentType]? {
        return list?.compactMap { return QUHomeComponentType(rawValue: $0) }
    }
}

struct QUHomeExchangeResult: BNCodable {
    
    var exchange: Int?
}
