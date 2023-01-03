//
//  Snap1ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/31/22.
//

import UIKit
import SnapKit

class Snap1ViewController: BaseViewController {

    // 外部方块
    lazy var boxOutter = UIView()
    // 内部方块
    lazy var boxInner = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boxOutter.backgroundColor = .orange
        view.addSubview(boxOutter)
        boxInner.backgroundColor = .green
        boxOutter.addSubview(boxInner)
        
        boxOutter.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(view).offset(-90.0).multipliedBy(0.5)
            make.height.equalTo(200)
            make.center.equalTo(self.view)
        }
         
        boxInner.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(100)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
    }

}

extension UIView {
    func superFirstView<T: UIView>(of: T.Type) -> T? {
        for view in sequence(first: self.superview, next: { $0?.superview}) {
            if let father = view as? T {
                return father
            }
        }
        return nil
    }
}
