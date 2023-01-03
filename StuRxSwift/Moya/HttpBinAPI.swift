//
//  HttpBinAPI.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Moya

// 初始化Httpbin.org请求做的provider
let HttpbinProvider = MoyaProvider<Httpbin>()

public enum Httpbin {
    case ip
    case anything(String) // 请求数据
}

extension Httpbin: TargetType {
    
    // 服务器地址
    public var baseURL: URL {
        return URL(string: "http://httpbin.org")!
    }
     
    // 各个请求的具体路径
    public var path: String {
        switch self {
        case .ip:
            return "/ip"
        case .anything:
            return "/anything"
        }
    }
     
    // 请求类型
    public var method: Moya.Method {
        return .post
    }
     
    // 请求任务事件（这里附带上参数）
    public var task: Task {
        switch self {
        case .anything(let param1):
            var params: [String: Any] = [:]
            params["param1"] = param1
            params["param2"] = "2017"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }

    // 请求头
    public var headers: [String: String]? {
        return nil
    }
}
