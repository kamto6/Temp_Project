//
//  QPHomeRequestManager.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/13.
//

import Foundation
import BNUMain

class QPHomeRequestManager {

    /// 请求我的关注列表
    /// - Returns: Observable
    static func fetchHomeDiscoverFollowList() -> Observable<BNHTTPResponse<QUHomeFollowListResult, BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverMyFollow, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: QUHomeFollowListResult.self)
    }
    
    /// 请求Banner列表
    /// - Returns: Observable
    static func fetchHomeDiscoverBannerList(position: Int) -> Observable<BNHTTPResponse<[QUHomeBannerModel], BNHTTPError>> {
        /// banner位置编号   0 首页 1 行情 2 交易 3 资讯 4 我的 6 搜索
        let params = ["positionCode": position]
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverBanner, params: params, method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: [QUHomeBannerModel].self)
    }
    
    /// 请求精选公司列表 - 首页
    /// - Returns: Observable
    static func fetchHomeDiscoverCompanyList(exchange: ExchangeType) -> Observable<BNHTTPResponse<QUHomePreferredCompanyResult, BNHTTPError>> {
        let params = ["exchange": exchange.rawValue]
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverCompany, params: params, method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: QUHomePreferredCompanyResult.self)
    }
    
    /// 请求特色股单列表 - 首页
    /// - Returns: Observable
    static func fetchHomeDiscoverHotStockOrderList() -> Observable<BNHTTPResponse<QUHomeHotStockOrderResult, BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverHotStockOrder, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: QUHomeHotStockOrderResult.self)
    }
    
    /// 请求成交热门列表 - 首页
    /// - Returns: Observable
    static func fetchHomeDiscoverHotDealList() -> Observable<BNHTTPResponse<QUHomeHotDealResult, BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverHotDeal, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: QUHomeHotDealResult.self)
    }
    
    /// 请求精选异动列表 - 首页
    /// - Returns: Observable
    static func fetchHomeDiscoverChoicenceChangeList() -> Observable<BNHTTPResponse<QUHomeChoicenceChangeResult, BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverChoicenceChange, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: QUHomeChoicenceChangeResult.self)
    }
    
    /// 请求24小时快讯列表 - 首页
    /// - Returns: Observable
    static func fetchHomeNewsFlashList() -> Observable<BNHTTPResponse<[QUNewsListModel], BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverNewsFlash, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: [QUNewsListModel].self)
    }
    
    /// 请求热门主题列表 - 首页
    /// - Returns: Observable
    static func fetchHomeNewsHotTopicList() -> Observable<BNHTTPResponse<[QUNewsHotTopicModel], BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverNewsHotTopic, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: [QUNewsHotTopicModel].self)
    }
    
    /// 请求当前交易市场 - 首页
    static func fetchHomeExchange() -> Observable<BNHTTPResponse<QUHomeExchangeResult, BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverGetExchange, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: QUHomeExchangeResult.self)
    }
    
    /// 请求当前交易市场 - 首页
    static func fetchHomePageIndex() -> Observable<BNHTTPResponse<QUHomePageIndexModel, BNHTTPError>> {
        let requestVo = BNCommonRequestVo(api: QUQuoteRequestUrl.discoverPageIndex, params: [:], method: .post)
        return CommonRequestAPIClient.shared.request(requestVo, modelType: QUHomePageIndexModel.self)
    }
    
}
