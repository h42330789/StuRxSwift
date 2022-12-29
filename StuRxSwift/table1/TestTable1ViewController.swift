//
//  TestTable1ViewController.swift
//  StuRxSwift
//
//  Created by abc on 12/21/22.
//

import UIKit
import RxCocoa
import RxSwift

class TestTable1ViewController: UIViewController {
    
    var tableView: UITableView!
    let disposeBag = DisposeBag()
    var items: BehaviorRelay<[String]>!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        items = BehaviorRelay(value: [
            "文本输入框的用法",
            "开关按钮的用法",
            "进度条的用法",
            "文本标签的用法",
        ])
        // 设置单元格数据
        items.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(row): \(element)"
            return cell
        }
        .disposed(by: disposeBag)
        
        // 获取选中项的索引
        tableView.rx.itemSelected
            .debug("AA:")
            .subscribe { [weak self] indexPath in
                let msg = "选中项的indexPath为：\(indexPath)"
                
                self?.showMessage(msg)
        }
        .disposed(by: disposeBag)
        
        // 获取选中项的内容
        tableView.rx.modelSelected(String.self).subscribe(onNext: {[weak self] item in
            self?.showMessage("选中项的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        //获取被取消选中项的索引
        tableView.rx.itemDeselected.subscribe(onNext: { [weak self] indexPath in
            self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
         
        //获取被取消选中项的内容
        tableView.rx.modelDeselected(String.self).subscribe(onNext: {[weak self] item in
            self?.showMessage("被取消选中项的的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        // 同时获取选中项的索引及内容
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .bind { [weak self] indexPath,item in
                self?.showMessage("选中项的indexPath为：\(indexPath)")
                self?.showMessage("选中项的标题为：\(item)")
            }
            .disposed(by: disposeBag)

    }
    

    func showMessage(_ msg: String) {
        print(msg)
    }

}
