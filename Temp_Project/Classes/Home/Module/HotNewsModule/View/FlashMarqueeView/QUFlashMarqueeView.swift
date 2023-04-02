//
//  QUFlashMarqueeView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation
import UIKit

class QUFlashMarqueeView: UIView {
    
    // MARK: - Properties
    
    var tapActionBlock: ((Int) -> Void)?
    
    /// 定时器时长
    var duration: TimeInterval = 3.0
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.isScrollEnabled = true
        view.bounces = true
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init { [weak self] recognizer in
            guard let self = self else { return }
            self.tapAction()
        }
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var topItem    = QUFlashMarqueeItem()
    private lazy var middleItem = QUFlashMarqueeItem()
    private lazy var bottomItem = QUFlashMarqueeItem()
    
    /// timer
    private var timer: Timer?
    
    private var dataList: [QUNewsListModel] = []
    
    /// 当前索引
    private var currentIndex: Int = 0
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        destroyTimer()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        scrollView.contentSize = CGSize(width: 0, height: scrollView.frame.size.height * 3.0)
        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.frame.size.height)
    }
    
    // MARK: - Publics
    
    func bindDatas(with list: [QUNewsListModel]) {
        dataList = list
        guard dataList.count > 1 else {
            destroyTimer()
            return
        }
        initTimer()
        updateContent()
    }
}

extension QUFlashMarqueeView {
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(topItem)
        scrollView.addSubview(middleItem)
        scrollView.addSubview(bottomItem)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        topItem.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        middleItem.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topItem.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(topItem)
        }
        bottomItem.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(middleItem.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(topItem)
        }
    }
    
    private func initTimer() {
        destroyTimer()
        timer = Timer.scheduledTimer(timeInterval: duration,
                                     target: self,
                                     selector: #selector(startAnimation),
                                     userInfo: nil,
                                     repeats: true)

        if let timer = timer {
            RunLoop.current.add(timer, forMode: .default)
        }
    }
    
    private func startTimer() {
//        timer?.fireDate = Date.distantPast
        /// 过4秒开启定时器
        timer?.fireDate = Date(timeInterval: duration, since: Date())
    }
    
    private func stopTimer() {
        timer?.fireDate = Date.distantFuture
    }
    
    private func destroyTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func startAnimation() {
        if !scrollView.isDragging || !scrollView.isDecelerating {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.frame.size.height * 2.0), animated: true)
        }
    }
    
    /// 防止索引过界
    private func limitCurrentIndex() {
        if currentIndex >= dataList.count {
            currentIndex = 0
        }
        if currentIndex < 0 {
            currentIndex = 0
        }
    }
    
    /// 上一页索引
    private func lastPageIndex() -> Int {
        return (currentIndex - 1 + dataList.count) % dataList.count
    }
    
    /// 下一页索引
    private func nextPageIndex() -> Int {
        return (currentIndex + 1 + dataList.count) % dataList.count
    }
    
    
    private func updateContent() {
        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.frame.size.height)
        limitCurrentIndex()
        let lastPageIndex = lastPageIndex()
        let nextPageIndex = nextPageIndex()
        
        if lastPageIndex < dataList.count {
            topItem.updateUI(model: dataList[lastPageIndex])
        }
        if currentIndex < dataList.count {
            middleItem.updateUI(model: dataList[currentIndex])
        }
        if nextPageIndex < dataList.count {
            bottomItem.updateUI(model: dataList[nextPageIndex])
        }
    }
    
    private func tapAction() {
        tapActionBlock?(currentIndex)
    }
    
}

extension QUFlashMarqueeView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard dataList.count > 1 else { return }
        let distance = scrollView.contentOffset.y - scrollView.frame.size.height
        if distance < 0 {
            currentIndex = lastPageIndex()
            updateContent()
        } else if distance > 0 {
            currentIndex = nextPageIndex()
            updateContent()
        }
        startTimer()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
}

