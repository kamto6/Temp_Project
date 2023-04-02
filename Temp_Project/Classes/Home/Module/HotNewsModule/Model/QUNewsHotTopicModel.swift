//
//  QUNewsHotTopicModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation

struct QUNewsHotTopicModel: BNCodable, Encodable, Decodable {
    /// 主题配图
    var pictureURL: String?
    /// 主题名称
    var title: String?
    /// 主题编号
    var topicId: String?
    /// 资讯内容
    var newsList: [QUNewsListModel]?
}

