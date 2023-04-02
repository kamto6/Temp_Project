//
//  QUPageScrollFlowLayout.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/26.
//

/// 分页滑动，滑动固定距离，pageScroll 设置为false

import Foundation

class QUPageScrollFlowLayout: UICollectionViewFlowLayout {
    
    /// 当前页数
    var page: Int = 0
    /// 上一次滑动偏移量
    var lastContentOffsetX: CGFloat = 0
        
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var lastRect: CGRect = .zero
        lastRect.origin = proposedContentOffset
        lastRect.size = (collectionView?.frame.size) ?? .zero
        
        let array = layoutAttributesForElements(in: lastRect)
        let startX = proposedContentOffset.x
        var adjustOffsetX = CGFloat.greatestFiniteMagnitude
        if abs(startX - lastContentOffsetX) >= itemSize.width * 0.5 {
            if startX > lastContentOffsetX {
                page += 1
            } else {
                if startX != lastContentOffsetX {
                    page -= 1
                    if page < 0 {
                        page = 0
                        lastContentOffsetX = 0
                    }
                }
            }
        }
        
        if let array = array, let attrs = array.first {
            let attrsW = attrs.frame.size.width
            adjustOffsetX = CGFloat(page) * (attrsW + minimumLineSpacing)
            lastContentOffsetX = adjustOffsetX
        }
        return CGPoint(x: adjustOffsetX, y: proposedContentOffset.y)
    }
    
}
