//
//  UIScrollView1ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import UIKit
import RxSwift
import RxCocoa

class UIScrollView1ViewController: UIViewController {

    lazy var disposeBag = DisposeBag()
    let tableData = BehaviorRelay<[String]>(value: [])
    var isLoading = BehaviorRelay<Bool>(value: false)
    var tableView: UITableView!
    var loadMoreView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(cellType: UITableViewCell.self)
        view.addSubview(tableView)
        setupInfiniteScrollingView()
        
        tableData.asDriver()
            .drive(tableView.rx.items) { (tv, row, element) in
                let cell = tv.dequeueReusableCell(for: IndexPath(row: row, section: 0), cellType: UITableViewCell.self)
                cell.textLabel?.text = "\(row)、\(element)"
                return cell
            }
            .disposed(by: disposeBag)
        
        isLoading.asDriver()
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.tableView.tableFooterView = self?.loadMoreView
                } else {
                    self?.tableView.tableFooterView = nil
                }
            }).disposed(by: disposeBag)
        
        tableView.rx.reachedBottom.asObservable()
            .startWith(())
            .flatMapFirst(getRandomResult)
            .subscribe(onNext: {[weak self] items in
                if let tableData = self?.tableData {
                   tableData.accept(tableData.value + items )
                }
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func getRandomResult() -> Driver<[String]> {
        print("正在请求数据。。。")
        self.isLoading.accept(true)
        // 随机生成20条数据
        let items = Array(0..<20).map { _ in "随机条目\(Int.random(in: 0...10))"}
        let observable = Observable.just(items)
        return observable.delay(.seconds(2), scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: Driver.empty())
    }
    
    private func setupInfiniteScrollingView() {
        self.loadMoreView = UIView(frame: .init(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: 40))
        loadMoreView.autoresizingMask = .flexibleWidth
        
        // 添加中间的环形进度条
        var activityViewIndicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityViewIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            // Fallback on earlier versions
            activityViewIndicator = UIActivityIndicatorView(style: .white)
        }
        let indecatorX = loadMoreView.frame.size.width/2 - activityViewIndicator.bounds.size.width/2
        let indicatorY = loadMoreView.frame.size.height/2 - activityViewIndicator.frame.size.height/2
        activityViewIndicator.frame = CGRect(x: indecatorX, y: indicatorY, width: activityViewIndicator.frame.size.width, height: activityViewIndicator.frame.size.height)
        activityViewIndicator.startAnimating()
        loadMoreView.addSubview(activityViewIndicator)
    }

}
