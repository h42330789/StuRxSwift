//
//  CustomePageWidthViewController.swift
//  StuRxSwift
//
//  Created by flow on 1/7/23.
//

import UIKit

// https://stackoverflow.com/questions/13492037/targetcontentoffsetforproposedcontentoffsetwithscrollingvelocity-without-subcla/13493707#13493707
// https://juejin.cn/post/6923007642168852494
class RowStyleLayout2: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x
        let targetRect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: 0), size: self.collectionView!.bounds.size)

        for layoutAttributes in super.layoutAttributesForElements(in: targetRect)! {
            let itemOffset = layoutAttributes.frame.origin.x
            if (abs(itemOffset - horizontalOffset) < abs(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}

class RowStyleLayout: UICollectionViewFlowLayout {
    private var lastOffset: CGPoint!
    
    override init() {
        super.init()
        lastOffset = .zero
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepare() {
        super.prepare()
        collectionView?.decelerationRate = .fast
    }
    
    // 这个方法的返回值，决定了CollectionView停止滚动时的偏移量
    /// 滚动时停下的偏移量
    /// - Parameters:
    ///   - proposedContentOffset: 将要停止的点
    ///   - velocity: 滚动速度
    /// - Returns: 滚动停止的点
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return .zero
        }
        // 分页的width
        let pageSpace = stepSpace()
        let offsetMax = collectionView.contentSize.width - pageSpace - sectionInset.left - minimumLineSpacing
        let offsetMin: CGFloat = 0
        
        // 修改之前记录的位置，如果小于最小的contentSize或者最大的contentSize则重置
        if lastOffset.x < offsetMin {
            lastOffset.x = offsetMin
        } else if lastOffset.x > offsetMax {
            lastOffset.x = offsetMax
        }
        
        // 目标位移点距离当前点距离的绝对值
        let offsetForCurrentPointX: CGFloat = abs(proposedContentOffset.x - lastOffset.x)
        let velocityX = velocity.x
        
        // 判断当前滑动方向，向左 true， 向右 false
        let isScrollLeft: Bool = (proposedContentOffset.x - lastOffset.x) > 0
        var newProposedContentOffset: CGPoint = .zero
        if offsetForCurrentPointX > (pageSpace / 8.0),
           lastOffset.x >= offsetMin,
           lastOffset.x <= offsetMax {
            // 分页因子，用于计算滑过的cell的数量,计算停下来后还会继续滚动的页数
            var pageFactor: NSInteger = 0
            if velocityX != 0 {
                // 滑动
                // 速率越快，cell 滑过的数量越多
                pageFactor = abs(Int(velocityX))
            } else {
                // 拖动
                pageFactor = abs(Int(offsetForCurrentPointX / pageSpace))
            }
            
            // 设置 pageFactor 的上限为2，防止滑动速率过大，导致翻页过多
            pageFactor = pageFactor < 1 ? 1 : (pageFactor < 3 ? 1 : 2)
            let pagexOffsetX: CGFloat = pageSpace * CGFloat(pageFactor)
            newProposedContentOffset = CGPoint(x: lastOffset.x + (isScrollLeft ? pagexOffsetX : -pagexOffsetX), y: proposedContentOffset.y)
        } else {
            // 滚动距离小于翻页，则不进行翻页
            newProposedContentOffset = CGPoint(x: lastOffset.x, y: lastOffset.y)
        }
        
        lastOffset.x = newProposedContentOffset.x
        return newProposedContentOffset
    }
    
    // 没滑动一页的间距
    func stepSpace() -> CGFloat {
        return itemSize.width + minimumLineSpacing
    }
}

class CutomPageCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = false
    }
}
class CustomePageWidthViewController: BaseViewController {
    lazy var collectionView: UICollectionView = {
        let layout = RowStyleLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumLineSpacing = 10
        let v = UICollectionView(frame: CGRect(x: 0, y: 100, width: 300, height: 200), collectionViewLayout: layout)
        v.register(cellType: CollectionFallCell.self)
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .systemBlue
//        v.isPagingEnabled = true
//        v.backgroundColor = .green
        return v
    }()
    
    lazy var collectionView2: UICollectionView = {
        let layout = RowStyleLayout2()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumLineSpacing = 10
        let v = CutomPageCollectionView(frame: CGRect(x: 0, y: collectionView.frame.maxY+20, width: 210, height: 200), collectionViewLayout: layout)
        v.register(cellType: CollectionFallCell.self)
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .systemPink
        v.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        v.clipsToBounds = false
        v.isPagingEnabled = true
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.addSubview(collectionView2)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView2.clipsToBounds = false
    }
}

extension CustomePageWidthViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CollectionFallCell.self)
        cell.backgroundColor = .random
        return cell
    }
}
