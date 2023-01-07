//
//  CollectionFixHeadViewController.swift
//  StuRxSwift
//
//  Created by flow on 1/7/23.
//

import UIKit

// 多列表格布局类
class UICollectionGridViewLayout: UICollectionViewLayout {
    // 记录每个单元格的布局属性
    private var itemAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var itemSize: [CGSize] = []
    private var contentSize: CGSize = .zero
    // 表格组件视图控制器

    override func prepare() {
        guard let collectionView = collectionView,
              let numberOfSections = self.collectionView?.numberOfSections,
              numberOfSections > 0
        else {
            return
        }
        // 这里可以优化，如果没有修改数据时，滑动只修改顶部和左侧的表头需要重新修改frame布局，其他不需要
        // 清空旧数据
        clearCache()
        // 计算内容每列单元格大小放到itemSize里
        calculateItemSize()

        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        (0 ..< numberOfSections).forEach { rowIndex in
            // 每一个section就是一行的数据
            let numberOfItems = collectionView.numberOfItems(inSection: rowIndex)
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            (0 ..< numberOfItems).forEach { colIndex in
                let itemSize = itemSize[colIndex]
                let indexPath = IndexPath(item: colIndex, section: rowIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                // 除第一列，其他列位置都左移一个像素，防止左右单元格间显示两条边框线
                if colIndex == 0 {
                    attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)
                } else {
                    attributes.frame = CGRect(x: xOffset - 0, y: yOffset, width: itemSize.width + 0, height: itemSize.height)
                }
                
                /***固定行头+列头**/
                if rowIndex == 0 && colIndex == 0 {
                    // 第一行并且是第一列
                    attributes.zIndex = 1024
                } else if rowIndex == 0 || colIndex == 0 {
                    // 第一行或第一列
                    attributes.zIndex = 1023
                }
                
                // 表头单元格位置固定
                if rowIndex == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    if frame.origin.y < 0 {
                        frame.origin.y = 0
                    }
                    attributes.frame = frame
                }
                
                // 首列单元格位置固定
                if colIndex == 0 {
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x + collectionView.contentInset.left
                    attributes.frame = frame
                }

//                // 如果是第一行（表头）
//                if rowIndex == 0 {
//                    // 猎头位置固定
//                    var frame = attributes.frame
//                    frame.origin.y = collectionView.contentOffset.y
//                    attributes.frame = frame
//                    // 列头单元格处于最顶层
//                    attributes.zIndex = 1024
//                }

                sectionAttributes.append(attributes)

                // 到了一行的最后一列前，x往后移动
                if colIndex < numberOfItems - 1 {
                    // 非最后一列，只变化x
                    xOffset += itemSize.width
                } else {
                    // 最后一列后，x、y都要变化
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }

            // 将一行的数据放入组中
            itemAttributes.append(sectionAttributes)
        }

        if let lastRow = itemAttributes.last,
           let lastCol = lastRow.last {
            let contentHeight = lastCol.frame.maxY
            let contentWidth = lastCol.frame.maxX
            contentSize = CGSize(width: contentWidth, height: contentHeight)
        }
    }

    // 需要更新layout时调用
    override func invalidateLayout() {
        clearCache()
        super.invalidateLayout()
    }

    // 返回内容区域总大小
    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    // 这个方法返回每个单元格的位置和大小
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.item]
    }

    // 返回所有单元格位置属性
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        itemAttributes.forEach { section in
            attributes.append(contentsOf: section.filter { rect.intersects($0.frame) })
        }
        
        return attributes
    }
    
    // 边界发生任何改变时（包括滚动条改变），都应该刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    func clearCache() {
        itemAttributes.removeAll()
        itemSize.removeAll()
        contentSize = .zero
    }
    
    func calculateItemSize() {
        guard let collectionView = self.collectionView,
              collectionView.numberOfSections > 0,
              let numberOfItems = self.collectionView?.numberOfItems(inSection: 0),
                numberOfItems > 0
        else {
            return
        }
        // 展示内容的可见区域
//        var remainingWidth = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
//        // 取出第一列的数量
//        var index = collectionView.numberOfItems(inSection: 0)
        (0 ..< numberOfItems).forEach { _ in
            // 先固定写死，实际是指定的或通过数据内容进行展示的
            itemSize.append(CGSize(width: 80, height: 40))
        }
    }
}

class CollectionFixHeadViewController: BaseViewController {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionGridViewLayout()
        let v = UICollectionView(frame: view.bounds.offsetBy(dx: 0, dy: 100), collectionViewLayout: layout)
        v.backgroundColor = .systemBlue
        v.register(cellType: CollectionFallCell.self)
        v.contentInset = .zero
//        v.adjustedContentInset = false
        v.bounces = false
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    lazy var titles: [String] = {
        return (0...100).map {"title\($0)"}
    }()
    
    lazy var gridList: [[String]] = {
        var list: [[String]] = []
        (0...100).forEach { _ in
            var rows: [String] = titles.map { _ in "-" }
            list.append(rows)
        }
        return list
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
       
    }
}

extension CollectionFixHeadViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if gridList.isEmpty {
            return 0
        }
        return gridList.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CollectionFallCell.self)
        cell.label.text = "\(indexPath)"
        if indexPath.section == 0 {
            // 第一行
            cell.label.text = titles[indexPath.item]
            cell.backgroundColor = .orange
        } else {
            cell.label.text = gridList[indexPath.section-1][indexPath.item]
            cell.backgroundColor = .lightGray
            if indexPath.item == 0 {
                cell.backgroundColor = .green
            }
        }
        
        return cell
    }
    
}
