//
//  GitHubViewModel2.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import ObjectMapper

class GitHubViewModel2 {
    private let searchAction: Driver<String>
    let networkService = GitHubNetworkService()
    
    let searchResult: Driver<GitHubRepositories>
    let responstires: Driver<[GitHubRepository]>
    let cleanResult: Driver<Void>
    let navigationTitle: Driver<String>
    
    init(searchAction: Driver<String>) {
        self.searchAction = searchAction
        
        self.searchResult = searchAction
            .filter { !$0.isEmpty }
            .flatMapLatest(networkService.searchResponstiresDriver)
        
        self.cleanResult = searchAction.filter { $0.isEmpty }
            .map { _ in Void() }
        
        self.responstires = Driver.merge(searchResult.map {$0.items},
                                         cleanResult.map {[]})
        
        self.navigationTitle = Driver.merge(
            searchResult.map { "共有 \($0.totalCount!) 个结果"},
            cleanResult.map { "hello.com"})
        
    }
}
