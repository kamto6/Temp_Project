//
//  QUNewsHotTopicControlller.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/17.
//

import Foundation
import BNUMain

class QUNewsHotTopicControlller: BNBaseViewController {
    
    // MARK: - Properties

    var reloadSuperViewUIBlock: ((Int) -> Void)?
    /// 左右边距、item之间的间距
    private let marginSpace: CGFloat = 12
    private let itemWidth = bnScaleFit(280)
    private let itemHeight = bnScaleFit(312)
    
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = marginSpace
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: bnScaleFit(20), bottom: 0, right: bnScaleFit(20))
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.palette.background
        view.delegate = self
        view.dataSource = self
        view.bounces = true
        view.register(QUNewsHotTopicCell.self, forCellWithReuseIdentifier: "QUNewsHotTopicCell")
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private var dataList: [QUNewsHotTopicModel] = []
    
    // MARK: - Init
    
    deinit {
        
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCacheData()
        fetchHomeNewsHotTopicList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Publics
    
    func headerRefresh() {
        fetchHomeNewsHotTopicList()
    }
    
}

extension QUNewsHotTopicControlller {
    
    // MARK: - Privates
    
    private func setupUI() {
        view.backgroundColor = Quote_White
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(itemHeight + 14)
        }
    }
    
    private func enterTopicDetail(topicModel: QUNewsHotTopicModel) {
        if let topicId = topicModel.topicId {
            let url = NewsTopicDetaiURL + "?id=\(topicId)"
            URLHelper.sharedInstance.jumpToBindController(urlString: url, extraParams: nil, operation: .push, animated: true)
        }
    }
    
    private func enterNewsDetail(topicModel: QUNewsHotTopicModel, newsModel: QUNewsListModel) {
        if let newsId = newsModel.newsId, let topicId = topicModel.topicId {
            let url = NewsDetaiURL + "?id=\(newsId)" + "&type=\(NewsType.important.rawValue)" + "&sid=\(topicId)"
            URLHelper.sharedInstance.jumpToBindController(urlString: url, extraParams: nil, operation: .push, animated: true)
        }
    }
    
}

extension QUNewsHotTopicControlller: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QUNewsHotTopicCell", for: indexPath) as? QUNewsHotTopicCell else {
            return UICollectionViewCell()
        }
        if indexPath.row < dataList.count {
            cell.updateUI(model: dataList[indexPath.row])
        }
        cell.topicDetailBlock = { [weak self] topic in
            guard let self = self else { return }
            self.enterTopicDetail(topicModel: topic)
        }
        cell.newsDetailBlock = { [weak self] topic, news in
            guard let self = self else { return }
            self.enterNewsDetail(topicModel: topic, newsModel: news)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
    }
    
}

extension QUNewsHotTopicControlller {
    
    /// 请求热门主题列表
    private func fetchHomeNewsHotTopicList() {
        QPHomeRequestManager.fetchHomeNewsHotTopicList().subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现热门主题列表失败，\(error.localizedDescription)")
            case .success(let response):
                self.dataList = response
                self.collectionView.reloadData()
                BNUserDefaultsStorage.setStructArray(self.dataList, forKey: QUUserStorageKey.discoverNewsTopicList.appendUserId())
            }
            self.reloadSuperViewUIBlock?(self.dataList.count)
        }).disposed(by: disposeBag)
    }
    
    /// 缓存
    private func loadCacheData() {
        let list = BNUserDefaultsStorage.structArrayData(QUNewsHotTopicModel.self, forKey: QUUserStorageKey.discoverNewsTopicList.appendUserId())
        self.dataList = list
    }
}
