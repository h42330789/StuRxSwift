//
//  Table8ViewController.swift
//  StuRxSwift
//
//  Created by abc on 12/24/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Reusable


class Table8ViewController: UIViewController {
    let disposeBag = DisposeBag()
    lazy var tableView: UITableView = {
        let t = UITableView(frame: view.bounds, style: .plain)
        t.register(cellType: Table8Cell.self)
        view.addSubview(t)
        return t
    }()
    
    lazy var items: BehaviorRelay<[TableSection8]> = {
        let br = BehaviorRelay(value: [
            TableSection8(header: "标题一", items: (0..<100).map{
                let model = Table8CellModel()
                model.key = "\($0)"
                model.playTitleList = ["a","b","c","d"]
                model.playContentList = ["1","2","3","4","5","6","7","8"]
                return model
            })
        ])
        return br
    }()
    
    lazy var dataSource = {
        let dt = RxTableViewSectionedReloadDataSource<TableSection8> { dataSource, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: Table8Cell.self)
            cell.type = self.type
            cell.textLabel?.text = "indexPath.row: \(indexPath.row)：key: \(element.key ?? "0")"
            cell.modelRelay.accept(element)
            cell.selectionStyle = .none
            return cell
        }
        dt.titleForHeaderInSection = { dataSource,index in
            return dataSource.sectionModels[index].header
        }
        return dt
    }()
    
    var type = (1,1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshBtn = UIBarButtonItem(title:"刷新")
        navigationItem.rightBarButtonItem = refreshBtn
        refreshBtn.rx.tap.subscribe(onNext:{ [weak self] in
            let oldType = self?.type ?? (0,0)
            var oldType1 = oldType.1 + 1
            if oldType1 > 3 {
                oldType1 = 1
            }
            self?.type = (oldType.0,oldType1)
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
//        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.delegate = self
        binding()
    }
    

    func binding() {
        items.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }


}

extension Table8ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}


struct TableSection8 {
    var header: String
    var items: [Table8CellModel]
}

extension TableSection8 : AnimatableSectionModelType {
    typealias Item = Table8CellModel
    
    var identity: String {
        return header
    }
    
    init(original: TableSection8, items: [Table8CellModel]) {
        self = original
        self.items = items
    }
}
