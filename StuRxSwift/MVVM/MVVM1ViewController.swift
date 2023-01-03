//
//  MVVM1ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import UIKit
import RxSwift
import RxCocoa

class MVVM1ViewController: BaseViewController {

    // 显示资源列表的tableView
    var tableView: UITableView!
     
    // 搜索栏
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建表视图
        self.tableView = UITableView(frame: self.view.frame, style: .plain)
        // 创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        // 创建表头的搜索栏
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0,
                                                   width: self.view.bounds.size.width, height: 56))
        self.tableView.tableHeaderView =  self.searchBar
        
        let searchAction = searchBar.rx.text.orEmpty
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asObservable()
        
        let viewModel = GitHubViewModel(searchAction: searchAction)
        viewModel.navigationTitle.bind(to: self.navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.respositories.bind(to: tableView.rx.items) { _, _, element in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = element.name
            cell.detailTextLabel?.text = element.htmlUrl
            return cell
        }.disposed(by: disposeBag)
        
        // 单元格点击
       tableView.rx.modelSelected(GitHubRepository.self)
           .subscribe(onNext: {[weak self] item in
               // 显示资源信息（完整名称和描述信息）
               self?.showAlert(title: item.fullName, message: item.description)
           }).disposed(by: disposeBag)
    }

}
