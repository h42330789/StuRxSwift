//
//  Table8Cell.swift
//  StuRxSwift
//
//  Created by abc on 12/24/22.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable



class Table8Cell: UITableViewCell {
    
    func createCollectionView(y:CGFloat, itemSize: CGSize,margin:CGFloat,cellType: UICollectionViewCell.Type,rowCount:CGFloat = 1, colCount: CGFloat = 2) -> UICollectionView {
        
       let flowLayout: UICollectionViewFlowLayout = {
           let flowLayout = UICollectionViewFlowLayout()
           flowLayout.scrollDirection = .horizontal
           flowLayout.minimumLineSpacing = margin
           flowLayout.minimumInteritemSpacing = rowCount == 0 ? 0 : margin/2
           flowLayout.itemSize = itemSize
           return flowLayout
       }()
        let width =  itemSize.width*colCount + margin*(colCount-1)
        let height = itemSize.height*rowCount + margin*(rowCount-1)
        let collectionV = UICollectionView.init(frame: CGRect(x: UIScreen.main.bounds.size.width - width - 10, y: y, width: width, height: height), collectionViewLayout: flowLayout)
       collectionV.backgroundColor = .clear
       collectionV.showsHorizontalScrollIndicator = false
       collectionV.bounces = false
       collectionV.register(cellType: cellType)
      return collectionV
    }
    
    lazy var titleCollectionView = createCollectionView(y: 10, itemSize: CGSize(width: 60, height: 20), margin: 5, cellType: Table8TitleCollectionCell.self)
    lazy var listCollectionView = createCollectionView(y: 50, itemSize: CGSize(width: 60, height: 40), margin: 5,cellType: Table8CollectionCell.self,rowCount: 2)
    
    
    let disposeBag: DisposeBag = DisposeBag()
    var type: KeyType = (-1,-1) {
        didSet {
            resetOffset()
        }
    }
    
    lazy var modelRelay = BehaviorRelay<Table8CellModel?>(value: nil)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        resetOffset()
        bindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let line = UIView(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.size.width, height: 1))
        line.backgroundColor = .lightGray.withAlphaComponent(0.3)
        contentView.addSubview(line)
        contentView.addSubview(titleCollectionView)
        contentView.addSubview(listCollectionView)
    }
    
    func resetOffset() {
        let offset = Table8StateTool.playOffset(type: self.type)
        self.titleCollectionView.contentOffset = offset
        self.listCollectionView.contentOffset = offset
    }
    
    func bindings() {
        // 绑定数据源
        modelRelay.map{$0?.playTitleList ?? []}
            .bind(to: titleCollectionView.rx.items){collectionView,row,element in
                let indexPath = IndexPath(item: row, section: 0)
                let cell = collectionView.dequeueReusableCell(for: indexPath) as Table8TitleCollectionCell
                cell.label.text = element
                return cell
            }
            .disposed(by: disposeBag)
        
        modelRelay.map{$0?.playContentList ?? []}
            .bind(to: listCollectionView.rx.items){ collectionView,row,element in
                let indexPath = IndexPath(item: row, section: 0)
                let cell = collectionView.dequeueReusableCell(for: indexPath) as Table8CollectionCell
                cell.label.text = element
                return cell
            }
            .disposed(by: disposeBag)
        // 将本cell的变化发送到其他上
  
        titleCollectionView.rx.contentOffset.skip(0)
            .subscribe(onNext: { [weak self] offset in
                let oldOffset = Table8StateTool.playOffset(type: self?.type)
                let res = offset.x != oldOffset.x
                if res {
                    let dict = Table8StateTool.offsetDict(type: self?.type, content: (offset,self?.titleCollectionView.contentSize ?? .zero))
                Table8StateTool.shared.playOffsetRelay.accept(dict)
            }
        })
            .disposed(by: disposeBag)
        
        // 将其他的变化对应到本cell上
        Table8StateTool.shared.playOffsetRelay.map{ [weak self] _ in
            return Table8StateTool.playOffset(type: self?.type)
        }
        .subscribe(onNext: { [weak self] offset in
            let oldOffset = self?.titleCollectionView.contentOffset ?? .zero
            let res = offset.x != oldOffset.x
            if res {
                self?.titleCollectionView.contentOffset = offset
            }
            
        })
        .disposed(by: disposeBag)
        
        // 将本cell的变化发送到其他上
        listCollectionView.rx.contentOffset.skip(0)
        .subscribe(onNext: { [weak self] offset in
            let oldOffset = Table8StateTool.playOffset(type: self?.type)
            let res = offset.x != oldOffset.x
            if res {
                let dict = Table8StateTool.offsetDict(type: self?.type, content: (offset,self?.titleCollectionView.contentSize ?? .zero))
                Table8StateTool.shared.playOffsetRelay.accept(dict)
            }

        })
        .disposed(by: disposeBag)
        
        listCollectionView.rx.modelSelected(String.self).subscribe(onNext: {[weak self] item in
            print("key:\(self?.modelRelay.value?.key ?? "") item:\(item)")
        })
        .disposed(by: disposeBag)
        // 将其他的变化对应到本cell上
        Table8StateTool.shared.playOffsetRelay.map{ [weak self] _ in
            return Table8StateTool.playOffset(type: self?.type)
        }
        .subscribe(onNext: { [weak self] offset in
            let oldOffset = self?.listCollectionView.contentOffset ?? .zero
            let res = offset.x != oldOffset.x
            if res {
                self?.listCollectionView.contentOffset = offset
            }
            
        })
        .disposed(by: disposeBag)
    }
}
