//
//  QUNewsListModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation

struct QUNewsListModel: BNCodable, Encodable, Decodable {
    
    /// 新闻编号/资讯Id
    var newsId: String?
    /// 发布时间
    var publicTime: String?
    /// 新闻标题
    var title: String?
}
