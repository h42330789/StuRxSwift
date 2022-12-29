//
//  ViewController.swift
//  StuRxSwift
//
//  Created by abc on 12/9/22.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable

extension UITableViewCell: Reusable {
    
}
extension UICollectionReusableView: Reusable {
    
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: view.bounds, style: .plain)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(t)
        return t
    }()
    
    lazy var items: BehaviorRelay<[UIViewController.Type]> = BehaviorRelay(value: [
        TestTable1ViewController.self,
        TestTable2ViewController.self,
        TestMyTable2ViewController.self,
        TestTable3ViewController.self,
        Table8ViewController.self,
        Collection1ViewController.self
    ])
    override func viewDidLoad() {
        super.viewDidLoad()
        items.bind(to: tableView.rx.items) { tableView, row, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: row, section: 0))
            cell.textLabel?.text = String(item.description()).components(separatedBy: ".").last
            return cell
        }.disposed(by: disposeBag)

        tableView.rx.modelSelected(UIViewController.Type.self)
            .subscribe{ [weak self] vcClz in
                let vc = vcClz.init()
                self?.navigationController?.pushViewController(vc, animated: true)
            
        }.disposed(by: disposeBag)
        
    }
    
    
    @IBAction func btnClicked(_ sender: Any) {
        self.navigationController?.pushViewController(TestTable2ViewController(), animated: true)
    }
    
}
