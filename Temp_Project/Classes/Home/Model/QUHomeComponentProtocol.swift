//
//  QUHomeComponentProtocol.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation

protocol QUHomeComponentProtocol: UIViewController {
 
    /// 下拉刷新
    func headerRefresh()

    /// 定时器刷新
    func timerRefresh()
    
    /// 定时器刷新间隔
    func timerDuration() -> TimeInterval?
    
    /// 涨跌色颜色变化
    func colorChanged()
}

extension QUHomeComponentProtocol {
    
    func timerRefresh() { }
    func timerDuration() -> TimeInterval? { return nil }
    func colorChanged() { }
}
