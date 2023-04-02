//
//  QUHomeBannerModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation

struct QUHomeBannerModel: BNCodable, Encodable, Decodable {
    var bannerUrl: String?  // banner图片url
    var endDate: String?    // 结束时间
    var forwardUrl: String? // banner跳转url
    var name: String?   // banner名称
    var orderNum: Int?  // 展示顺序，值越小越靠前
    var position: String?   // banner放置位置
    var positionCode: String? // banner放置位置编号
    var product: String?   // 产品名称
    var startDate: String? // 开始时间
    var status: Int?    // 状态，0 待上架 1 已上架 2 已下架
    var statusDesc: String? // 状态描述
    var tag: Int? // 0 无需跳转 1 App页面 2 外部链接
    var isSkeleton: Bool?
    
}
