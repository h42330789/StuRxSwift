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

struct BookInfo {
    var name: String
    var pages: Int
}

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
        Collection1ViewController.self,
        Share1ViewController.self,
        UIScrollView1ViewController.self,
        RxFeedBack1ViewController.self,
        RxFeedBack2ViewController.self,
        RxFeedBack3ViewController.self,
        SportLightViewController.self,
        UNNotificationViewController.self,
        Snap1ViewController.self,
        Moya1ViewController.self,
        Moya2ViewController.self,
        MVVM1ViewController.self,
        MVVM2ViewController.self,
        CollectionFallViewController.self,
        CollectionHorPageViewController.self,
        CollectionDecorationViewController.self,
        CollectionFixHeadViewController.self,
        CustomePageWidthViewController.self
    ].reversed())
    override func viewDidLoad() {
        super.viewDidLoad()
        items.bind(to: tableView.rx.items) { tableView, row, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: row, section: 0))
            cell.selectionStyle = .none
            cell.textLabel?.text = String(item.description()).components(separatedBy: ".").last
            return cell
        }.disposed(by: disposeBag)

        tableView.rx.modelSelected(UIViewController.Type.self)
            .subscribe { [weak self] vcClz in
                let vc = vcClz.init()
                self?.navigationController?.pushViewController(vc, animated: true)
            
        }.disposed(by: disposeBag)
        
//        var booka = BookInfo(name: "A", pages: 10)
//        let list = [booka]
//        print("1-> name: \(booka.name) \(booka.pages)")
////        booka.pages = 100
//        print("2-> name: \(booka.name) \(booka.pages)")
//        print(booka)
//        print(list.first)
//        var booka1 = booka
//        booka1.pages = 100
//        print(booka)
//        print(booka1)
        
    }
    
    @IBAction func btnClicked(_ sender: Any) {
        self.navigationController?.pushViewController(TestTable2ViewController(), animated: true)
    }
    
}
