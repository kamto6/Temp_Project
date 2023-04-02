//
//  QUBannerView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/29.
//

import Foundation
import UIKit

protocol QUBannerViewDelegate: NSObjectProtocol {
    
    func bannerView(_ bannerView: QUBannerView, didSelectItemAt index: Int)
    func bannerView(_ bannerView: QUBannerView, didScrollTo index: Int)
}

class QUBannerView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: QUBannerViewDelegate?
    
    /// 定时器时长
    var duration: TimeInterval = 5.0
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.isPagingEnabled = true
        view.isScrollEnabled = true
        view.bounces = false
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
    
    private lazy var leftItem: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = BgColor
        return view
    }()
    
    private lazy var middleItem: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = BgColor
        return view
    }()
    
    private lazy var rightItem: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = BgColor
        return view
    }()
    
    /// timer
    private var timer: Timer?
    
    private var dataList: [String] = []
    
    /// 当前索引
    private var currentIndex: Int = 0
    
    /// 间隙
    private var itemSpace: CGFloat = bnScaleFit(40)
    
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
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3.0, height: 0)
//        scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
    }
    
    // MARK: - Publics
    
    func bindDatas(with list: [String]) {
        dataList = list
        guard dataList.count > 1 else {
            destroyTimer()
            return
        }
        initTimer()
        updateContent()
    }
}

extension QUBannerView {
    
    // MARK: - Privates
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(leftItem)
        scrollView.addSubview(middleItem)
        scrollView.addSubview(rightItem)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        leftItem.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(itemSpace * 0.5)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-itemSpace)
            make.height.equalToSuperview()
        }
        middleItem.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(leftItem.snp.right).offset(itemSpace)
            make.width.equalToSuperview().offset(-itemSpace)
            make.height.equalTo(leftItem)
        }
        rightItem.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(middleItem.snp.right).offset(itemSpace)
            make.width.equalToSuperview().offset(-itemSpace)
            make.height.equalTo(leftItem)
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
        /// 过5秒开启定时器
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
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width * 2.0, y: 0), animated: true)
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
        scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
        limitCurrentIndex()
        let lastPageIndex = lastPageIndex()
        let nextPageIndex = nextPageIndex()
        
        if lastPageIndex < dataList.count {
            leftItem.loadImage(urlStr: dataList[lastPageIndex], placeholder: nil)
        }
        if currentIndex < dataList.count {
            middleItem.loadImage(urlStr: dataList[currentIndex], placeholder: nil)
        }
        if nextPageIndex < dataList.count {
            rightItem.loadImage(urlStr: dataList[nextPageIndex], placeholder: nil)
        }
        delegate?.bannerView(self, didScrollTo: currentIndex)
    }
    
    private func tapAction() {
        delegate?.bannerView(self, didSelectItemAt: currentIndex)
    }
    
}

extension QUBannerView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard dataList.count > 1 else { return }
        let distance = scrollView.contentOffset.x - scrollView.frame.size.width
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
