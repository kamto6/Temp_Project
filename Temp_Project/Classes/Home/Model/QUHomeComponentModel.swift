//
//  QUHomeComponentModel.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import UIKit

enum QUHomeComponentType: Int {
    /// 未开户、未入金、资产信息
    case assert = 1
    /// 我的关注
    case followlist = 2
    /// 轮播图
    case banner = 3
    /// 精选公司
    case preferredCompany = 4
    /// 特色股单
    case specialStockOrder = 5
    /// 机会追踪
    case opportunityTrack = 6
    /// 热点资讯
    case hotNews = 7
    
    var title: String {
        switch self {
        case .assert:            return ""
        case .followlist:         return NSLocalizedString("我的关注", comment: "")
        case .banner:            return ""
        case .preferredCompany:  return NSLocalizedString("精选公司", comment: "")
        case .specialStockOrder: return NSLocalizedString("特色股单", comment: "")
        case .opportunityTrack:  return NSLocalizedString("机会追踪", comment: "")
        case .hotNews:           return NSLocalizedString("热点资讯", comment: "")
        }
    }
    
}

/// 模块model
struct QUHomeComponentModel {
    /// 标题
    var title: String?
    /// 控制器
    var controller: QUHomeComponentProtocol?
    /// 类名
    var classType: UIViewController.Type?
    /// 模块类型
    var type: QUHomeComponentType?
    /// 显隐
    var isHidden: Bool?
    /// 顺序
    var rank: Int?

}
