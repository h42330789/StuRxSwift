//
//  MoyaMyServiceAPI.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Moya
 
// 初始化请求的provider
let MoyaMyServiceProvider = MoyaProvider<MoyaMyService>()

// 定义下载的DownloadDestination（不改变文件名，同名文件不会覆盖）
private let DefaultDownloadDestination: DownloadDestination = { _, response in
    return (DefaultDownloadDir.appendingPathComponent(response.suggestedFilename!), [])
}
 
// 默认下载保存地址（用户文档目录）
let DefaultDownloadDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

// 请求分类
public enum MoyaMyService {
    case uploadFile0(value1: String, value2: Int, file1Data: Data, file2URL: URL) // 上传文件
    case uploadFile(value1: String, value2: Int, file1Data: Data, file2URL: URL) // 上传文件
    case uploadFile2(value1: String, value2: Int, file1Data: Data, file2URL: URL) // 上传文件
    case downloadAsset(assetName: String)  // 下载文件
}
 
// 请求配置
extension MoyaMyService: TargetType {
    // 服务器地址
    public var baseURL: URL {
        switch self {
        case let .uploadFile0(value1, value2, _, _):
            return URL(string: "http://www.hangge.com/upload.php?value1=\(value1)&value2=\(value2)")!
        default:
            return URL(string: "http://www.hangge.com")!
        }
        
    }
     
    // 各个请求的具体路径
    public var path: String {
        switch self {
        case .uploadFile0:
            return ""
        case let .downloadAsset(assetName):
            return  "/assets/\(assetName)"
        default:
            return "/upload.php"
        }
        
    }
     
    // 请求类型
    public var method: Moya.Method {
        switch self {
        case .downloadAsset:
            return .get
        default:
            return .post
        }
    }
     
    // 请求任务事件（这里附带上参数）
    public var task: Task {
        switch self {
        case let .uploadFile0(_, _, _, fileURL):
            return .uploadFile(fileURL)
        case let .uploadFile(value1, value2, file1Data, file2URL):
            // 字符串
            let strData = value1.data(using: .utf8)
            let formData1 = MultipartFormData(provider: .data(strData!), name: "value1")
            // 数字
            let intData = String(value2).data(using: .utf8)
            let formData2 = MultipartFormData(provider: .data(intData!), name: "value2")
            // 文件1
            let formData3 = MultipartFormData(provider: .data(file1Data), name: "file1",
                                              fileName: "hangge.png", mimeType: "image/png")
            // 文件2
            let formData4 = MultipartFormData(provider: .file(file2URL), name: "file2",
                                              fileName: "h.png", mimeType: "image/png")
             
            let multipartData = [formData1, formData2, formData3, formData4]
            return .uploadMultipart(multipartData)
        case let .uploadFile2(value1, value2, file1Data, file2URL):
            // 跟随url传递的参数
            let urlParameters: [String: Any] = ["value1": value1, "value2": value2]
            // 文件1
            let formData3 = MultipartFormData(provider: .data(file1Data), name: "file1",
                                             fileName: "hangge.png", mimeType: "image/png")
            // 文件2
            let formData4 = MultipartFormData(provider: .file(file2URL), name: "file2",
                                             fileName: "h.png", mimeType: "image/png")
             
            let multipartData = [formData3, formData4]
            return .uploadCompositeMultipart(multipartData, urlParameters: urlParameters)

        case .downloadAsset:
            return .downloadDestination(DefaultDownloadDestination)
   
        }
    }
     
    // 是否执行Alamofire验证
    public var validate: Bool {
        return false
    }
     
    // 这个就是做单元测试模拟的数据，只会在单元测试文件中有作用
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
     
    // 请求头
    public var headers: [String: String]? {
        return nil
    }
}
