//
//  GitHubNetworkService.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import Foundation
import Moya
import ObjectMapper
import RxCocoa
import RxSwift

typealias SearchRepositoriesResponse = GitHubResult<GitHubRepositories, GitHubServiceError>

// 响应结果枚举
enum GitHubResult<T, E: Error> {
    case success(T) // 成功 （里面是返回的数据）
    case failure(E) // 失败 （里面是错误原因）
}

// 失败情况枚举
enum GitHubServiceError: Error {
    case offline
    case githubLimitReached
}

// 失败枚举对应的错误信息
extension GitHubServiceError {
    var displayMessage: String {
        switch self {
        case .offline:
            return "网络连接失败！"
        case .githubLimitReached:
            return "请求太频繁，请稍后再试！"
        }
    }
}

class GitHubNetworkService {
    // 验证用户名是否存在
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        // 通过检查这个用户的Github主页是否存在来判断用户是否存在
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return URLSession.shared.rx.response(request: request)
            .map { pair in
                pair.response.statusCode == 404
            }
            .catchAndReturn(false)
    }

    // 注册用户
    func signup(_ username: String, password: String) -> Observable<Bool> {
        // 模拟注册，（平均每3次有1次失败）
        let signupResult = Int.random(in: 0 ..< 3) == 0 ? false : true
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

    // 搜索资源数据
//    func searchRepositories2(query:String) -> Observable<SearchRepositoriesResponse> {
//        return GitHubProvider.rx.request(.repositories(query))
//            .filterSuccessfulStatusCodes()
//            .mapJSON()
//            .map {
//                Mapper<GitHubRepositories>().map(JSON: ($0 as? [String: Any]) ?? [:], toObject: GitHubRepositories())
//            }
    ////            .map { .success($0) }
    ////            .catch { error in
    ////                print("发生错误：",error.localizedDescription)
    ////                // 失败返回（GitHub接口对请求频率有限制，太频繁会被拒绝：403）
    ////                return Observable.just(SearchRepositoriesResponse.failure(.githubLimitReached))
    ////            }
//    }
}
