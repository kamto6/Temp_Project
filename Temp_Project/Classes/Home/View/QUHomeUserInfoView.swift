//
//  QUHomeUserInfoView.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/12.
//

import Foundation
import UIKit
import BNUMain

class QUHomeUserInfoView: UIView {
    
    // MARK: - Properties
    
    var userLogoClickBlock: (() -> Void)?
    
    private let kUserLogoWidth = bnScaleFit(34)
    
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = kUserLogoWidth * 0.5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bnFont(fontStyle: .Medium, fontSize: 16)
        label.textColor = Quote_Gray1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var tapView: UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer.init { [weak self] recognizer in
            guard let self = self else { return }
            self.userLogoClickBlock?()
        }
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addNotification()
        updateUI()
    }
    
    // MARK: - Publics
    
    @objc func updateUI() {
        if let userInfoModel = BNQuoteMainManager.shared.getUserInfoModel() {
            userNameLabel.text = userInfoModel.nickname
            userImageView.loadImageSyncQueryDisk(urlStr: userInfoModel.picUrl ?? "", placeholder: UIImage(bnNamed: "static_user_mine_logo"))
        } else {
            userNameLabel.text = NSLocalizedString("未登录", comment: "")
            userImageView.image = UIImage(bnNamed: "static_user_mine_logo")
        }
    }
    
    func reloadFrame() {
        /// 更新frame，防止导航栏titleView pop push UI错乱
        frame = CGRect(origin: .zero, size: CGSize(width: kScreenW, height: frame.size.height))
    }
    
}

extension QUHomeUserInfoView {
    
    // MARK: - Notifications
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(nkUserLoginSucceed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(nkUserDidLogoutSucceed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: nkUserGetUserInfoSucceed), object: nil)
    }
    
    // MARK: - Privates
    
    private func setupUI() {
        addSubview(userImageView)
        addSubview(userNameLabel)
        addSubview(tapView)
        
        userImageView.frame = CGRect(x: 10, y: (frame.size.height - kUserLogoWidth) * 0.5, width: kUserLogoWidth, height: kUserLogoWidth)
        userNameLabel.frame = CGRect(x: userImageView.frame.origin.x + userImageView.frame.size.width + bnScaleFit(10), y: (frame.size.height - kUserLogoWidth) * 0.5, width: 100, height: kUserLogoWidth)
        tapView.frame = CGRect(x: 0, y: 0, width: userNameLabel.origin.x + userNameLabel.frame.size.width + 20, height: frame.size.height)
    }
    
}
