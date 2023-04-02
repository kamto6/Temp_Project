//
//  QUNewsFlashController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation
import UIKit
import BNUMain

class QUNewsFlashController: BNBaseViewController {
    
    // MARK: - Properties
    
    private lazy var bgImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_news_flash_bg")
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var titleLogo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_news_flash_logo")
        return view
    }()
    
    private lazy var verticalLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.color(colorHexString: "#E9E9E9")
        return view
    }()
    
    private lazy var marqueeView: QUFlashMarqueeView = {
        let view = QUFlashMarqueeView()
        view.duration = 5.0
        view.tapActionBlock = { [weak self] index in
            guard let self = self else { return }
            self.tapAction(with: index)
        }
        return view
    }()
    
    private let maxShowCount = 12
    private var dataList: [QUNewsListModel] = []
    
    // MARK: - Init
 
    deinit {
        
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCacheData()
        fetchHomeNewsFlashList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Publics
    
    func headerRefresh() {
        fetchHomeNewsFlashList()
    }
    
    func timerRefresh() {
        fetchHomeNewsFlashList()
    }
    
}

extension QUNewsFlashController {
    
    // MARK: - Privates
    
    private func setupUI() {
        view.addSubview(bgImageView)
        bgImageView.addSubview(titleLogo)
        bgImageView.addSubview(verticalLine)
        bgImageView.addSubview(marqueeView)
        
        bgImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(bnScaleFit(14))
            make.right.equalToSuperview().offset(-bnScaleFit(14))
            make.height.equalTo(bnScaleFit(76))
        }
        titleLogo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(16))
            make.top.equalToSuperview().offset(bnScaleFit(14))
        }
        verticalLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(70))
            make.top.equalToSuperview().offset(bnScaleFit(14))
            make.width.equalTo(1)
            make.height.equalTo(bnScaleFit(44))
        }
        marqueeView.snp.makeConstraints { make in
            make.centerY.equalTo(verticalLine)
            make.left.equalTo(verticalLine.snp.right).offset(bnScaleFit(12))
            make.width.equalTo(bnScaleFit(246))
            make.height.equalTo(bnScaleFit(52))
        }
    }
    
    private func tapAction(with index: Int) {
        if index < dataList.count, let newsId = dataList[index].newsId {
            let url = NewsDetaiURL + "?id=\(newsId)" + "&type=\(NewsType.flash.rawValue)"
            URLHelper.sharedInstance.jumpToBindController(urlString: url, extraParams: nil, operation: .push, animated: true)
        }
    }
    
}

extension QUNewsFlashController {
    
    /// 请求24小时快讯列表
    private func fetchHomeNewsFlashList() {
        QPHomeRequestManager.fetchHomeNewsFlashList().subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现24小时快讯列表失败，\(error.localizedDescription)")
            case .success(let response):
                self.dataList = response
                if self.dataList.count > self.maxShowCount {
                    self.dataList = Array(self.dataList[0 ... self.maxShowCount - 1])
                }
                self.marqueeView.bindDatas(with: self.dataList)
                BNUserDefaultsStorage.setStructArray(self.dataList, forKey: QUUserStorageKey.discoverNewsFlashList.appendUserId())
            }
        }).disposed(by: disposeBag)
    }
    
    /// 缓存
    private func loadCacheData() {
        let list = BNUserDefaultsStorage.structArrayData(QUNewsListModel.self, forKey: QUUserStorageKey.discoverNewsFlashList.appendUserId())
        dataList = list
        marqueeView.bindDatas(with: dataList)
    }
    
}
