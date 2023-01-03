//
//  GitHubViewModel.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class GitHubViewModel {
    // 输入部分
    fileprivate let searchAction: Observable<String>
    let networkService = GitHubNetworkService()
    // 输出部分
    let searchResult: Observable<GitHubRepositories>
    let respositories: Observable<[GitHubRepository]>
    let cleanResult: Observable<Void>
    let navigationTitle: Observable<String>
    
    init(searchAction: Observable<String>) {
        self.searchAction = searchAction
        
        // 生成查询结果序列
        searchResult = searchAction
            .filter { !$0.isEmpty }
            .flatMapLatest(networkService.searchResponstires)
            .share(replay: 1) // 让HTTP请求是被共享的
        
        // 生成清空结果动作序列
        self.cleanResult = searchAction.filter { $0.isEmpty }.map { _ in Void()}
        // 生成查询结果里的资源列表序列
        self.respositories = Observable.of(
            searchResult.map {$0.items},
            cleanResult.map {[]})
        .merge()
        // 生成导航标题序列
        self.navigationTitle = Observable.of(
            searchResult.map {"共有 \($0.totalCount!) 个结果"},
            cleanResult.map { "hello.com"})
        .merge()
    }
}
