//
//  TestTable5ViewController.swift
//  StuRxSwift
//
//  Created by abc on 12/22/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TestTable5ViewController: UIViewController {
    let disposeBag = DisposeBag()
    lazy var tableView: UITableView = {
        let t = UITableView(frame: view.bounds, style: .plain)
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(t)
        return t
    }()
    
    lazy var initialVM = Test5ViewModel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshBtn = UIBarButtonItem(title: "刷新")
        let addBtn = UIBarButtonItem(title: "+")
        self.navigationItem.rightBarButtonItems = [addBtn,refreshBtn]
        
        // 刷新数据
//        let refreshCommand = refreshBtn.rx.tap
//            .startWith(()) // 加这个为了让一开始就能自动请求一次数据
//            .flatMapFirst{ getRandomResult }  //连续请求时只取第一次数据
//            .map(TableEditingCommand.setItems)
//            
//        // 新增条目
//        let addCommand = addBtn.rx.tap
//            .map{ _ in "\(arc4random())"}
//            .map{TableEditingCommand.addItem}
//        
//        // 移动位置命令
//        let moveCommand = tableView.rx.itemMoved
//            .map{_ in TableEditingCommand.moveItem}
//        
//        // 删除条目命令
//        let deleteCommand = tableView.rx.itemDeleted
//            .map{_ in TableEditingCommand.deleteItem}
//        
//        Observable.of(refreshCommand,addCommand,moveCommand,deleteCommand)
//            .merge()
//            .scan(initialVM) { (vm: Test5ViewModel, command: TableEditingCommand) -> Test5ViewModel in
//                return vm.execute(command: command)
//            }
//            .startWith(initialVM)
//            .map{
//                [AnimatableSectionModel(model: "", items: $0.items)]
//            }
//            .share(replay: 1)
//            .bind(to: tableView.rx.items(dataSource: dataSource()))
//            .disposed(by: disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            tableView.setEditing(true, animated: true)
        }
         
        //获取随机数据
        func getRandomResult() -> Observable<[String]> {
            print("生成随机数据。")
            let items = (0 ..< 5).map {_ in
                "\(arc4random())"
            }
            return Observable.just(items)
        }

}

extension TestTable5ViewController {
    //创建表格数据源
     func dataSource() -> RxTableViewSectionedAnimatedDataSource
        <AnimatableSectionModel<String, String>> {
        return RxTableViewSectionedAnimatedDataSource(
            //设置插入、删除、移动单元格的动画效果
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: {
                (dataSource, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                return cell
        },
            canEditRowAtIndexPath: { _, _ in
                return true //单元格可删除
        },
            canMoveRowAtIndexPath: { _, _ in
                return true //单元格可移动
        }
        )
    }
}
