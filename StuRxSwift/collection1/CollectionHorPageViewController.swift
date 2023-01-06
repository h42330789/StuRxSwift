//
//  CollectionHorPageViewController.swift
//  StuRxSwift
//
//  Created by aaa on 1/6/23.
//

import UIKit

/**
 参考：
 https://juejin.cn/post/6844903533498597384
 https://juejin.cn/post/6844903533507002376
 */

class HorPageCollectionViewFlowLayout: UICollectionViewFlowLayout {
    // 是否在不满一页时，展示空白补足一页
    var isPageEmpty: Bool = true
    // 左右列间距 默认是0
    var colSpacing: CGFloat = 0
    // 上下 行间距 默认是0
    var rowSpacing: CGFloat = 0
    // 上下左右的间距
    var sectionInsets: UIEdgeInsets = .zero
    // 每页的列数 默认是2
    var columnCount: Int = 2
    // 每页的行数 默认是2
    var rowCount: Int = 2
    private var attributes: [UICollectionViewLayoutAttributes] = []

    lazy var cacheContentSize: CGSize = .zero

    func cacluCacheContentSize() {
        // 水平滚动，高度固定，宽度根据内容获取
        guard let collectionView = collectionView else { return }

        let countOfPage = rowCount * columnCount
        let itemCount: Int = collectionView.numberOfItems(inSection: 0)
        let pageCount: Int = (itemCount + countOfPage - 1) / countOfPage
        var size = collectionView.frame.size
        // 水平滚动，高度是满屏，宽度根据内容展示
        size.width = CGFloat(pageCount) * collectionView.frame.width
        cacheContentSize = size
    }

    private var innelItemSize: CGSize = .zero
    private var cacheItemSize: CGSize {
        if innelItemSize.width > 0, innelItemSize.height > 0 {
            // 返回缓存的结果
            return innelItemSize
        }
        guard let collectionView = collectionView,
              let sectionCount = collectionView.dataSource?.numberOfSections?(in: collectionView),
              sectionCount > 0
        else { return .zero }
        // 获取collectionView的宽
        let width = collectionView.frame.width
        // 每一行总的item的宽度
        let totalWidht = width - sectionInsets.left - sectionInsets.right - CGFloat(columnCount - 1) * colSpacing
        let itemWidth = totalWidht / CGFloat(columnCount)
        let height = collectionView.frame.height
        let totalHeight = height - sectionInsets.top - sectionInsets.bottom - CGFloat(rowCount - 1) * rowSpacing
        let itemHeight = totalHeight / CGFloat(rowCount)
        // 计算item的高度
        innelItemSize = CGSize(width: itemWidth, height: itemHeight)
        // 返回计算的结果
        return innelItemSize
    }

    func clearCache() {
        attributes.removeAll()
        cacheContentSize = .zero
    }

    override var collectionViewContentSize: CGSize {
        if cacheContentSize.height <= 0 {
            cacluCacheContentSize()
        }
        return cacheContentSize
    }

    // 重写prepare方法
    // 这个方法必须重写，它用来告诉layout要更改当前的布局，也可以在这个方法里做一些准备工作
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        // 特定场景下才需要清空缓存
        if attributes.count > 0 {
            return
        }
        clearCache()
        let itemCount: Int = collectionView.numberOfItems(inSection: 0)
        // index->IndexPath->UICollectionViewLayoutAttributes->保存
        (0 ..< itemCount).map { IndexPath(item: $0, section: 0) }
            .compactMap { layoutAttributesForItem(at: $0) }
            .forEach {
                attributes.append($0)
            }
        // 计算整个collectionView的contentSize
        cacluCacheContentSize()
    }

    // 重写layoutAttributesForItem方法，用来计算每个cell的大小
    // 子类必须重写此方法，并使用它来返回集合视图中项目的布局信息
    // 您可以使用此方法仅为具有相应单元格的项目提供布局信息

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // 第一组的内容的数量，总共只有一组
        let countOfPage = Int(rowCount * columnCount)
        let index = indexPath.item
        let pageIndex = CGFloat(Int(index / countOfPage))
        let count = index % countOfPage
        let rowIndex = CGFloat(Int(count / columnCount))
        let colIndex = CGFloat(Int(count % columnCount))

        let pageWidth = collectionView?.frame.width ?? 0
        let itemX = pageIndex * pageWidth + colIndex * (cacheItemSize.width + colSpacing) + sectionInsets.left
        let itemY = rowIndex * (cacheItemSize.height + rowSpacing) + sectionInsets.top

        // 设置attributes的frame
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.frame = CGRect(x: itemX, y: itemY, width: cacheItemSize.width, height: cacheItemSize.height)
        return attribute
    }

    // 子类必须重写此方法，并使用它返回视图与指定矩形相交的所有项的布局信息
    // 您的实现应该返回所有可视元素的属性，包括单元格，补充视图和装饰视图
    // 创建布局属性时，始终穿件表示正确的类型（单元格，补充或装饰）的属性对象。
    // 集合视图区分每种类型的属性，并使用该信息来决定要创建的视图以及如何管理它们
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
}

class CollectionHorPageViewController: BaseViewController {
    lazy var collectionView1: UICollectionView = {
        let layout = HorPageCollectionViewFlowLayout()
        layout.rowCount = 3
        layout.columnCount = 4
        layout.rowSpacing = 10
        layout.colSpacing = 10
        layout.sectionInsets.left = 5
        layout.sectionInsets.right = 5
        let v = UICollectionView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 200), collectionViewLayout: layout)
        v.register(cellType: CollectionFallCell.self)
        v.isPagingEnabled = true
        v.dataSource = self
        v.delegate = self
        return v
    }()

    lazy var collectionView2: UICollectionView = {
        let layout = HorPageCollectionViewFlowLayout()
        layout.rowCount = 4
        layout.columnCount = 6
        layout.rowSpacing = 10
        layout.colSpacing = 5
        let v = UICollectionView(frame: CGRect(x: 0, y: collectionView1.frame.maxY + 50, width: view.bounds.width, height: 300), collectionViewLayout: layout)
        v.register(cellType: CollectionFallCell.self)
        v.dataSource = self
        v.delegate = self
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView1)
        view.addSubview(collectionView2)
        // Do any additional setup after loading the view.
    }
}

extension CollectionHorPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CollectionFallCell.self)
        cell.label.text = "\(indexPath)"
        cell.backgroundColor = .random()
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView2 {
            return 88
        }
        return 50
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}
