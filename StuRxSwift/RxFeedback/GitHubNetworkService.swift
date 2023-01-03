//
//  GitHubNetworkService.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import Moya

class GitHubNetworkService {
    // 验证用户名是否存在
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        // 通过检查这个用户的Github主页是否存在来判断用户是否存在
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return URLSession.shared.rx.response(request: request)
            .map { pair in
                return pair.response.statusCode == 404
            }
            .catchAndReturn(false)
    }
    
    // 注册用户
    func signup(_ username: String, password: String) -> Observable<Bool> {
        // 模拟注册，（平均每3次有1次失败）
        let signupResult = Int.random(in: (0..<3)) == 0 ? false : true
        return Observable.just(signupResult)
            .delay(.microseconds(1500), scheduler: MainScheduler.instance)
    }
    
    // 搜索资源数据
    func searchResponstires(query: String) -> Observable<GitHubRepositories> {
        return GitHubProvider.rx.request(.repositories(query))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map {
                Mapper<GitHubRepositories>().map(JSON: ($0 as? [String: Any]) ?? [:], toObject: GitHubRepositories())
            }
            .asObservable()
            .catch { error in
                print("发生错误：", error.localizedDescription)
                return Observable<GitHubRepositories>.empty()
            }
    }
    static func searchResponstiresDriver(query: String) -> Driver<GitHubRepositories> {
        return GitHubProvider.rx.request(.repositories(query))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map {
                Mapper<GitHubRepositories>().map(JSON: ($0 as? [String: Any]) ?? [:], toObject: GitHubRepositories())
            }
            .asDriver(onErrorDriveWith: Driver.empty())
    }
    func searchResponstiresDriver(query: String) -> Driver<GitHubRepositories> {
        return GitHubProvider.rx.request(.repositories(query))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map {
                Mapper<GitHubRepositories>().map(JSON: ($0 as? [String: Any]) ?? [:], toObject: GitHubRepositories())
            }
            .asDriver(onErrorDriveWith: Driver.empty())
    }
        
}
