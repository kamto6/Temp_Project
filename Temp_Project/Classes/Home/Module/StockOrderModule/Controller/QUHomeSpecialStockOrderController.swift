//
//  QUHomeSpecialStockOrderController.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import BNUMain
import UIKit

class QUHomeSpecialStockOrderController: BNBaseViewController {
    
    // MARK: - Properties
    
    /// 最外层容器
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 最外层容器高度
    private let kContainerHeight = bnScaleFit(248)
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 18)
        label.textColor = Quote_Gray1
        label.textAlignment = .left
        label.text = QUHomeComponentType.specialStockOrder.title
        return label
    }()
    
    /// 查看更多
    private lazy var detailButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(bnNamed: "static_quote_seemore_right_arrow"), for: .normal)
        button.setTitle(NSLocalizedString("更多", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.bnFont(fontStyle: .Regular, fontSize: 14)
        button.setTitleColor(Gray3, for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.adjustImageTitlePosition(.right, spacing: 5)
        button.addTarget(self, action: #selector(detailMoreClick), for: .touchUpInside)
        return button
    }()
    
    /// 请求失败
    private var hadRequestedFail = false
    
    /// 最多展示的item个数
    private let maxShowCount: Int = 20
    /// 左右边距、item之间的间距
    private let itemSpace: CGFloat = bnScaleFit(12)
    private let lineSpace: CGFloat = 12
    private let itemWidth = kScreenW - bnScaleFit(33)
    private let itemHeight = bnScaleFit(54)
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = QUPageScrollFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = itemSpace
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: bnScaleFit(8), bottom: 0, right: bnScaleFit(25))
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.palette.background
        view.delegate = self
        view.dataSource = self
        view.bounces = true
        view.register(QUHomeSpecialStockOrderCell.self, forCellWithReuseIdentifier: "QUHomeSpecialStockOrderCell")
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private var dataList: [QUHomeHotStockOrderCellModel] = []
    
    // MARK: - Init
    
    deinit {
        
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCacheData()
        fetchSpeocialStockOrderList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Publics
    
}

extension QUHomeSpecialStockOrderController: QUHomeComponentProtocol {
    
    func headerRefresh() {
        fetchSpeocialStockOrderList()
    }
    
    func timerRefresh() {
        fetchSpeocialStockOrderList()
    }
    
    func timerDuration() -> TimeInterval? {
        return 15
    }
    
    func colorChanged() {
        collectionView.reloadData()
    }
    
    // MARK: - Notifications
    
    // MARK: - Action
    
    // MARK: - Privates
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kContainerHeight)
            make.bottom.equalToSuperview()
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailButton)
        containerView.addSubview(collectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(bnScaleFit(20))
            make.top.equalToSuperview().offset(bnScaleFit(16))
            make.height.equalTo(bnScaleFit(25))
        }
        detailButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-bnScaleFit(20))
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        let collectionViewHeight = ceil(itemHeight * CGFloat(3) + itemSpace * CGFloat(2))
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(bnScaleFit(14))
            make.height.equalTo(collectionViewHeight)
        }
    }
    
    /// 有数据时显示该卡片，无数据时卡片隐藏
    private func reloadContainerState() {
        view.isHidden = dataList.count <= 0
    }
    
    @objc private func detailMoreClick() {
        QUFlutterHelper.shared.jumpToFlutterController(.hotStockOrders)
    }
    
    private func stockDetailClick(stockModel: StockQueryParameter) {
        BNQuoteJumpHelper.jumpStockDetailVc(exchange: stockModel.exchange, code: stockModel.stockCode, categoryType: stockModel.categoryType)
    }
    
}

extension QUHomeSpecialStockOrderController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QUHomeSpecialStockOrderCell", for: indexPath) as? QUHomeSpecialStockOrderCell else {
            return UICollectionViewCell()
        }
        if indexPath.row < self.dataList.count {
            cell.updateUI(model: self.dataList[indexPath.row])
        } else {
            cell.updateEmptyUI()
        }
        cell.stockDetailBlock = { [weak self] stock in
            guard let self = self else { return }
            self.stockDetailClick(stockModel: stock)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hadRequestedFail {
            return 3
        } else {
            return self.dataList.count
        }
    }
    
}

extension QUHomeSpecialStockOrderController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.row < dataList.count, let orderId = dataList[indexPath.row].orderId {
            QUFlutterHelper.shared.jumpToFlutterController(.stockOrderDetail, arguments: ["orderId": orderId])
        }
    }
}

extension QUHomeSpecialStockOrderController {
    
    private func fetchSpeocialStockOrderList() {
        QPHomeRequestManager.fetchHomeDiscoverHotStockOrderList().subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .failure(let error):
                QuoteLogger.debug("首页发现特色股单列表失败，\(error.localizedDescription)")
                self.hadRequestedFail = self.dataList.count <= 0
                self.collectionView.reloadData()
            case .success(let response):
                self.dataList.removeAll()
                if let list = response.list {
                    self.dataList = list.map { return QUHomeHotStockOrderCellModel(model: $0) }
                }
                self.hadRequestedFail = false
                self.collectionView.reloadData()
                BNUserDefaultsStorage.setStruct(response, forKey: QUUserStorageKey.discoverStockOrderList.appendUserId())
                self.reloadContainerState()
            }
        }).disposed(by: disposeBag)
    }

    /// 缓存
    private func loadCacheData() {
        let response = BNUserDefaultsStorage.structData(forKey: QUUserStorageKey.discoverStockOrderList.appendUserId(), type: QUHomeHotStockOrderResult.self)
        if let list = response?.list {
            dataList = list.map { return QUHomeHotStockOrderCellModel(model: $0) }
        }
    }
}
