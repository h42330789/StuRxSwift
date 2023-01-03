//
//  TestTable3ViewController.swift
//  StuRxSwift
//
//  Created by abc on 12/22/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TestTable3ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let t = UITableView(frame: view.bounds, style: .plain)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        t.tableHeaderView = searchBar
        view.addSubview(t)
        return t
    }()
    
    lazy var dataSource = {
        let dt = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>> { _, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
            return cell
        }
        dt.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model
        }
        return dt
    }()
    
    lazy var searchBar = {
        let bar = UISearchBar(frame: .init(x: 0, y: 0, width: self.view.bounds.size.width, height: 56))
        return bar
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshBtn = UIBarButtonItem(title: "刷新", style: .plain, target: nil, action: nil)
        let stopBtn = UIBarButtonItem(title: "停止", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItems = [refreshBtn, stopBtn]
        
        let randomResult = refreshBtn.rx.tap
//            .asObservable()
//            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .startWith(()) // 加这个为了让一开始就能自动请求一次数据
//            .flatMapLatest(getRandomResult)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .flatMapFirst {
                self.getRandomResult().take(until: stopBtn.rx.tap)
            }  // 连续请求时只取第一次数据
            .share(replay: 1)
        
        randomResult.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("正在请求数据。。。。。。")
        let items = (0..<5).map {_ in Int.random(in: (0...1000))}
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(.seconds(2), scheduler: MainScheduler.instance)
    }
    
}
