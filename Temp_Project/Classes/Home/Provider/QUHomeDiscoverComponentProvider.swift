//
//  QUHomeDiscoverComponentProvider.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation

class QUHomeDiscoverComponentProvider {

    
    static let defalultConfigList: [QUHomeComponentType] = [.assert, .followlist, .banner, .preferredCompany, .specialStockOrder, .opportunityTrack, .hotNews]
    
    static var classMap: [QUHomeComponentType: UIViewController.Type] {
        return [QUHomeComponentType.assert: QUHomeAssertController.self,
                QUHomeComponentType.followlist: QUHomeFollowListController.self,
                QUHomeComponentType.banner: QUHomeBannerController.self,
                QUHomeComponentType.preferredCompany: QUHomePreferredCompanyController.self,
                QUHomeComponentType.specialStockOrder: QUHomeSpecialStockOrderController.self,
                QUHomeComponentType.opportunityTrack: QUHomeOpportunityTrackController.self,
                QUHomeComponentType.hotNews: QUHomeHotNewsController.self
                ]
    }
    
    /// 加载默认的排序
    static func getDefaultSubComponent() -> [QUHomeComponentModel] {
        if let pageIndexModel = BNUserDefaultsStorage.structData(forKey: QUUserStorageKey.discoverRankList.rawValue, type: QUHomePageIndexModel.self), let cachedList = pageIndexModel.typeList {
            return getSubComponentList(with: cachedList)
        }
        return getSubComponentList(with: defalultConfigList)
    }
    
    /// 更新组件
    static func loadSubComponentTypes() -> [QUHomeComponentType]? {
        if let pageIndexModel = QPHomePageManager.sharedInstance.pageIndexModel, let typeIndexList = pageIndexModel.typeList {
            var configList = defalultConfigList
            if let pageIndexModel = BNUserDefaultsStorage.structData(forKey: QUUserStorageKey.discoverRankList.rawValue, type: QUHomePageIndexModel.self), let cachedList = pageIndexModel.typeList {
                configList = cachedList
            }
            if allItemEqual(array: configList, antherArray: typeIndexList) == false {
                return typeIndexList
            }
        }
        return nil
    }
    
    /// 获取组件列表
    static func getSubComponentList(with list: [QUHomeComponentType]) -> [QUHomeComponentModel] {
        /// 配置子模块
        /// classType:为界面的类，后面会根据类，自动创建对象
        var componentList: [QUHomeComponentModel] = []
        for type in list {
            if let model = getSubComponent(with: type) {
                componentList.append(model)
            }
        }
        return componentList
    }
    
    /// 获取当前类型的组件
    static func getSubComponent(with type: QUHomeComponentType) -> QUHomeComponentModel? {
        if let classType = classMap[type] as? QUHomeComponentProtocol.Type {
            
            var model = QUHomeComponentModel()
            model.title = type.title
            model.type = type
            model.classType = classType
            /// 初始化子模块
            model.controller = classType.init()
            return model
        }
        return nil
    }
    
    /// 两个数组的元素是否相等
    private static func allItemEqual(array: [QUHomeComponentType], antherArray: [QUHomeComponentType]) -> Bool {
        if array.count != antherArray.count {
            return false
        }
        for (i, item) in array.enumerated() {
            if item != antherArray[i] {
                return false
            }
        }
        return true
    }
    
}
