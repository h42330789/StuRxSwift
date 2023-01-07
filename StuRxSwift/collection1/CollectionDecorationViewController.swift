//
//  CollectionDecorationViewController.swift
//  StuRxSwift
//
//  Created by flow on 1/7/23.
//

import UIKit

/**
 参考：
 https://www.hangge.com/blog/cache/detail_1844.html
 https://juejin.cn/post/6942356138960617508
*/

@objc protocol SectionBgCollectionViewDelegate {
    // 增加自定义的协议，使其可以像cell那样根据数据源来配置section背景色
    func collectionView(_ collectionView: UICollectionView,
                        layout collecctionViewLayout: UICollectionViewLayout,
                        backgroundColorForSectionAt section: Int) -> UIColor
}

private class SectionBgCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    // 背景色
    var backgroundColor = UIColor.white

    // 所定义属性的类型需要尊从 NSCoppying协议
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        if let scopy = super.copy(with: zone) as? SectionBgCollectionViewLayoutAttributes {
            scopy.backgroundColor = self.backgroundColor
        }
        return copy
    }

    // 所定义属性的类型需要实现相等判断方法
    override func isEqual(_ object: Any?) -> Bool {
        // 于比较的对象类型不一样，不相等
        guard let rhs = object as? SectionBgCollectionViewLayoutAttributes else {
            return false
        }

        // 颜色不一样就表示不一样
        if !self.backgroundColor.isEqual(rhs.backgroundColor) {
            return false
        }

        // 剩下属性使用父类的判断
        return super.isEqual(object)
    }
}

private class SectionBgCollectionReusableView: UICollectionReusableView {
    // 通过apply方法让自定义属性生效
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let attr = layoutAttributes as? SectionBgCollectionViewLayoutAttributes else {
            return
        }

        self.backgroundColor = attr.backgroundColor
    }
}

class SectionBgCollectionViewLayout: UICollectionViewFlowLayout {
    private var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []

    weak var sectionDelegate: SectionBgCollectionViewDelegate?

    override init() {
        super.init()
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    func setup() {
        // 注册自定义用来作为背景的 Decoration 视图
        self.register(SectionBgCollectionReusableView.self, forDecorationViewOfKind: SectionBgCollectionReusableView.description())
    }

    // 对一些布局的准备操作放在这里
    override func prepare() {
        super.prepare()

        // 如果collectionView当前没有分区，或者未实现相关的代理则结束
        guard let collectionView = self.collectionView,
              let numberOfSections = self.collectionView?.numberOfSections,
              numberOfSections > 0
        else {
            return
        }

        // 删除原来的section背景的布局属性
        self.decorationViewAttrs.removeAll()

        // 分别计算每个section背景的布局属性
        for section in 0 ..< numberOfSections {
            // 获取该section下第一个，以及最后一个item的布局属性
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection: section),
                  numberOfItems > 0,
                  let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                  let lastItem = layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section))
            else {
                continue
            }

            // 获取该section的内边距
            var sectionInset = self.sectionInset
            if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
               let inset = flowDelegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) {
                sectionInset = inset
            }

            // 计算得到该section实际的位置
            var sectionFrame = firstItem.frame.union(lastItem.frame)
            sectionFrame.origin.x = 0
            sectionFrame.origin.y -= sectionInset.top

            // 计算得到该section实际的尺寸
            if scrollDirection == .horizontal {
                sectionFrame.size.width += sectionInset.left + sectionInset.right
                sectionFrame.size.height = collectionView.frame.height
            } else {
                sectionFrame.size.width = collectionView.frame.width
                sectionFrame.size.height += sectionInset.top + sectionInset.bottom
            }

            // 根据上面的结果计算section背景的布局属性
            let attr = SectionBgCollectionViewLayoutAttributes(forDecorationViewOfKind: SectionBgCollectionReusableView.description(), with: IndexPath(item: 0, section: section))
            attr.frame = sectionFrame
            attr.zIndex = -1
            // 通过代理方法获取该section背景使用的颜色
            attr.backgroundColor = self.sectionDelegate?.collectionView(collectionView, layout: self, backgroundColorForSectionAt: section) ?? .white
            // 将该section背景的布局属性保存起来
            self.decorationViewAttrs.append(attr)
        }
    }

    // 返回rect范围下所有元素的布局属性（这里自定义的section背景属性也一起返回）
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)
        // 找到显示区域相交的区域
        let decorateAttr = self.decorationViewAttrs.filter { rect.intersects($0.frame) }
        attrs?.append(contentsOf: decorateAttr)
        return attrs
    }

    // 返回对应于indexPath的位置的Decoration视图的布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // 如果是自定义的Decoratino视图（section背景），则返回它的布局属性
        if elementKind == SectionBgCollectionReusableView.description() {
            return self.decorationViewAttrs[indexPath.section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
}

class CollectionDecorationViewController: BaseViewController {
    lazy var collectionView: UICollectionView = {
        let layout = SectionBgCollectionViewLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.sectionDelegate = self
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        v.register(cellType: CollectionFallCell.self)
        v.isPagingEnabled = true
        v.dataSource = self
        v.delegate = self
        
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(self.collectionView)
    }
}

extension CollectionDecorationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SectionBgCollectionViewDelegate {
    // 返回分区数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    // 返回每个分区下单元格个数
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 奇数section里有8个单元格，偶数section里有4个单元格
        return (section % 2 == 1) ? 4 : 8
    }

    // 返回每个单元格视图
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CollectionFallCell.self)
        cell.backgroundColor = UIColor.white
        cell.label.text = "\(indexPath)"
        return cell
    }

    // 返回每个分区的内边距
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        return numberOfItems > 0 ? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) :
            UIEdgeInsets.zero
    }

    // 返回每个分区的背景色
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        backgroundColorForSectionAt section: Int) -> UIColor {
        if section == 0 {
            return UIColor.green
        } else if section == 1 {
            return UIColor.cyan
        } else if section == 2 {
            return UIColor.blue
        }
        return UIColor.purple
    }
}
