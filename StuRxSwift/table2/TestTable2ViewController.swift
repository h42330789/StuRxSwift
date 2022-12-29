//
//  TestTable2ViewController.swift
//  StuRxSwift
//
//  Created by abc on 12/21/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TestTable2ViewController: UIViewController {
    lazy var tableView: UITableView = {
        let t = UITableView(frame: view.bounds, style: .plain)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(t)
        return t
    }()
    
   
    lazy var items: BehaviorRelay<[SectionModel]> = {
        let br = BehaviorRelay(value: [
            SectionModel(model: "AA", items: [
                "UILabel的用法",
                "UIText的用法",
                "UIButton的用法",
            ])
        ])
        return br
    }()
    
    lazy var dataSource = {
        let dt = RxTableViewSectionedReloadDataSource<SectionModel<String,String>> { dataSource, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(indexPath.row)：\(element)"
            return cell
        }
        dt.titleForHeaderInSection = { dataSource,index in
            return dataSource.sectionModels[index].model
        }
        return dt
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        binding()
    }
    
    func binding() {
        items.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}

class TestMyTable2ViewController: UIViewController {
    lazy var tableView: UITableView = {
        let t = UITableView(frame: view.bounds, style: .plain)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(t)
        return t
    }()
    
   
    lazy var items: BehaviorRelay<[MySection]> = {
        let br = BehaviorRelay(value: [
            MySection(header: "标题一", items: [
                "UILabel的用法",
                "UIText的用法",
                "UIButton的用法",
            ]),
            MySection(header: "标题二", items: [
                "UILabel的用法2",
                "UIText的用法2",
                "UIButton的用法2",
            ])
        ])
        return br
    }()
    
    lazy var dataSource = {
        let dt = RxTableViewSectionedReloadDataSource<MySection> { dataSource, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(indexPath.row)：\(element)"
            return cell
        }
        dt.titleForHeaderInSection = { dataSource,index in
            return dataSource.sectionModels[index].header
        }
        return dt
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        binding()
    }
    
    func binding() {
        items.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}

struct MySection {
    var header: String
    var items: [String]
}

extension MySection : AnimatableSectionModelType {
    typealias Item = String
    
    var identity: String {
        return header
    }
    
    init(original: MySection, items: [String]) {
        self = original
        self.items = items
    }
}
