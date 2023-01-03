//
//  MoyaNetwork.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Foundation
import Moya
import SwiftyJSON

struct MoyaNetwork {
    static let provider = MoyaProvider<DouBan>()
    
    static func request(
        _ target: DouBan,
        success successCallback: @escaping (JSON) -> Void,
        error errorCallback: @escaping (Int) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    // 如果数据返回成功则直接将结果转为JOSN
                    _ = try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    successCallback(json)
                } catch let error {
                    // 如果数据获取失败，则返回错误状态码
                    // swiftlint:disable force_cast
                    errorCallback((error as! MoyaError).response!.statusCode)
                }
            case let .failure(error):
                failureCallback(error)
            }
        }
    }
}
