//
//  Collection1ViewController.swift
//  StuRxSwift
//
//  Created by abc on 12/27/22.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable

class MyCollectionViewCell: UICollectionViewCell {
    lazy var label: UILabel = {
        let v = UILabel(frame: .init(x: 0, y: 0, width: 100, height: 20))
        v.textAlignment = .center
        contentView.addSubview(v)
        contentView.backgroundColor = .orange
        return v
    }()
}

class Collection1ViewController: UIViewController {

    let disposeBag = DisposeBag()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 110, height: 70)
        layout.scrollDirection = .horizontal
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        v.register(cellType: MyCollectionViewCell.self)
        view.addSubview(v)
        return v
    }()
    
    lazy var items = Observable.just((0...10).map({$0}))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        items.bind(to: collectionView.rx.items){ cv,item,element in
            let indexPath = IndexPath(item: item, section: 0)
            let cell = cv.dequeueReusableCell(for: indexPath) as MyCollectionViewCell
            cell.label.text = "\(element)"
            return cell
        }
        .disposed(by: disposeBag)
        
        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(Int.self))
            .bind { [weak self] indexPath, item in
                self?.showMessage("选中项的indexPath为：\(indexPath)")
                self?.showMessage("选中项的标题为：\(item)")
            }
            .disposed(by: disposeBag)
    }
    
    func showMessage(_ msg: String) {
        print(msg)
    }

}
