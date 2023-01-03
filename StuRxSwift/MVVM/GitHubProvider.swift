//
//  GitHubProvider.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Foundation
import Moya
/*
* 下面定义GitHub请求的endpoints（供provider使用）
*/
// 初始化GitHub请求的provider
let GitHubProvider = MoyaProvider<GitHubAPI>()

// 请求分类
public enum GitHubAPI {
    case repositories(String)  // 查询资源库
}
 
// 请求配置
extension GitHubAPI: TargetType {
    // 服务器地址
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    // 各个请求的具体路径
    public var path: String {
        switch self {
        case .repositories:
            return "/search/repositories"
        }
    }
    
    // 请求类型
    public var method: Moya.Method {
        return .get
    }
    
    // 请求任务事件（这里附带上参数）
    public var task: Task {
        print("发起请求。")
        switch self {
        case .repositories(let query):
            var params: [String: Any] = [:]
            params["q"] = query
            params["sort"] = "stars"
            params["order"] = "desc"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String: String]? {
        return nil
    }
}
