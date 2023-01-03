//
//  MoyaDouBanAPI.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Foundation
import Moya

// 初始化豆瓣FM请求的provider
let DouBanProvider = MoyaProvider<DouBan>()

public enum DouBan {
    case channels // 获取频道类别
    case playlist(String) // 获取歌曲
}

extension DouBan: TargetType {
    
    // 服务器地址
    public var baseURL: URL {
        switch self {
        case .channels:
            return URL(string: "https://www.douban.com")!
        case .playlist:
            return URL(string: "https://douban.fm")!
        }
    }
    
    // 各个请求的具体路径
    public var path: String {
        switch self {
        case .channels:
            return "/j/app/radio/channels"
        case .playlist:
            return "/j/mine/playlist"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        switch self {
        case .playlist(let channel):
            var params: [String: Any] = [:]
            params["channel"] = channel
            params["type"] = "n"
            params["from"] = "mainsite"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    // 请求头
    public var headers: [String: String]? {
        return nil
    }
}
