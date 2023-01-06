//
//  CollectionFallViewController.swift
//  StuRxSwift
//
//  Created by aaa on 1/6/23.
//

import UIKit

@objc protocol FallCollectionViewLayoutDelegate {
    // waterFall的列数
    func columnOfWaterFall(_ collectionView: UICollectionView) -> Int

    // 每个item的高度
    func waterFall(_ collectionView: UICollectionView,
                   layout waterFallLayout: FallCollectionViewLayout,
                   heightForItemAt indexPath: IndexPath) -> CGFloat
}

class FallCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: FallCollectionViewLayoutDelegate?
    // 列数 默认是2
    var columnCount: CGFloat = 2
    // 列间距 默认是0
    var columnSpacing: CGFloat = 0
    // 行间距 默认是0
    var lineSpacing: CGFloat = 0
    // sectino 和collectionView 的间距 默认是 (0,0,0,0)
    var sectionInsets: UIEdgeInsets = .zero

    // sectionTop
    var sectionTop: CGFloat = 0 {
        willSet {
            sectionInsets.top = newValue
        }
    }

    var sectionBottom: CGFloat = 0 {
        willSet {
            sectionInsets.bottom = newValue
        }
    }

    var sectionLeft: CGFloat = 0 {
        willSet {
            sectionInsets.left = newValue
        }
    }

    var sectionRight: CGFloat = 0 {
        willSet {
            sectionInsets.right = newValue
        }
    }

    // 列对应的当前的最大的Y
    private var columnHeightDict: [Int: CGFloat] = [:]
    private var attributes: [UICollectionViewLayoutAttributes] = []

    init(lineSpacing: CGFloat, columnSpacing: CGFloat, sectionInsets: UIEdgeInsets) {
        super.init()
        self.lineSpacing = lineSpacing
        self.columnSpacing = columnSpacing
        self.sectionInsets = sectionInsets
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // 重写父类方法， 子类必须重写此方法，并使用它返回collectionView的内容的宽度和高度。
    // 这些值表示所有的内容的宽度和高度，而不仅仅是当前可见的内容。
    // collectionView使用此信息来配置自己的内容大小以用以滚动目的
    lazy var cacheContentSize: CGSize = .zero
    override var collectionViewContentSize: CGSize {
        if cacheContentSize.height <= 0 {
            cacluCacheContentSize()
        }
        return cacheContentSize
    }

    private var itemWidth: CGFloat = 0
    private var cacheItemWidth: CGFloat {
        if itemWidth > 0 {
            // 返回缓存的结果
            return itemWidth
        }
        guard let collectionView = collectionView,
              let columnCount = delegate?.columnOfWaterFall(collectionView),
              columnCount > 0
        else { return 0 }
        // 获取collectionView的宽
        let width = collectionView.frame.width
        // 每一行总的item的宽度
        let totalWidht = width - sectionInsets.left - sectionInsets.right - CGFloat(columnCount - 1) * columnSpacing
        // 每一个item的宽度
        let cacheItemWidth = totalWidht / CGFloat(columnCount)
        // 计算item的高度
        itemWidth = cacheItemWidth
        // 返回计算的结果
        return cacheItemWidth
    }

    private lazy var cacheAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]

    func cacluCacheContentSize() {
        // 处理完数据，缓存高度
        let maxHeight: CGFloat = columnHeightDict.values.max() ?? 0
        cacheContentSize = CGSize(width: collectionView?.frame.width ?? 0, height: maxHeight)
    }

    func clearCache() {
        attributes.removeAll()
        cacheAttributes.removeAll()
        cacheContentSize = .zero
    }

    // 重写prepare方法
    // 这个方法必须重写，它用来告诉layout要更改当前的布局，也可以在这个方法里做一些准备工作
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        clearCache()
        guard let columnCount = delegate?.columnOfWaterFall(collectionView),
              columnCount > 0
        else {
            return
        }
        // 给每一列设置初始的y
        (0 ..< columnCount).forEach { columnHeightDict[$0] = sectionInsets.top }

        // 第一组的内容的数量，总共只有一组
        let itemCount = collectionView.numberOfItems(inSection: 0)

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
        // 根据indexPath获取item的attributes
        if let attribute = cacheAttributes[indexPath] {
            // 有缓存的就使用缓存的数据
            return attribute
        }

        // 列数超过0才进行计算
        guard let collectionView = collectionView,
              let columnCount = delegate?.columnOfWaterFall(collectionView),
              columnCount > 0
        else { return nil }

        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        // 计算item的高度
        let itemHeight = delegate?.waterFall(collectionView, layout: self, heightForItemAt: indexPath) ?? 0

        // 找出最短的一列
        let minColIndex = columnHeightDict.min {
            // 取值小的那个
            if $0.value < $1.value {
                return true
            }
            // 由于字典的迭代未必是无序的，所以如果有多个相同的最小的值，当前业务需要取最小的key
            if $0.value == $1.value, $0.key < $1.key {
                return true
            }
            return false
        }?.key ?? 0

        // 根据最短列的列数计算 item的 x值
        let itemX = sectionInsets.left + (columnSpacing + cacheItemWidth) * CGFloat(minColIndex)

        // item的y值 = 最短列的最大+行间距
        let itemY = (columnHeightDict[minColIndex] ?? 0) + lineSpacing

        // 设置attributes的frame
        attribute.frame = CGRect(x: itemX, y: itemY, width: cacheItemWidth, height: itemHeight)
        columnHeightDict[minColIndex] = attribute.frame.maxY

        // 缓存attribute
        cacheAttributes[indexPath] = attribute
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

// MARK: - controller
class CollectionFallViewController: BaseViewController {
    lazy var collectionView: UICollectionView = {
        let layout = FallCollectionViewLayout(lineSpacing: 10, columnSpacing: 20, sectionInsets: .init(top: 10, left: 15, bottom: 10, right: 15))
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        v.register(cellType: CollectionFallCell.self)
        v.dataSource = self
        v.delegate = self
        layout.delegate = self
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(relaod))
    }

    @objc func relaod() {
        collectionView.reloadData()
    }
}

extension CollectionFallViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FallCollectionViewLayoutDelegate {
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
        return 100
    }

    func waterFall(_ collectionView: UICollectionView, layout waterFallLayout: FallCollectionViewLayout, heightForItemAt indexPath: IndexPath) -> CGFloat {
        return CGFloat([100, 200, 150, 120].randomElement() ?? 0)
    }

    func columnOfWaterFall(_ collectionView: UICollectionView) -> Int {
        return 3
    }
}

// MARK: - Cell
import SnapKit
class CollectionFallCell: UICollectionViewCell {
    lazy var label: UILabel = {
        let v = UILabel(frame: .zero)
        v.textAlignment = .center
        v.textColor = .red
        contentView.addSubview(v)
        v.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return v
    }()
}
