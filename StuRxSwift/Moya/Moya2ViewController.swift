//
//  Moya2ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import UIKit
import SwiftyJSON
import Reusable

class Moya2ViewController: BaseViewController {
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: view.bounds, style: .plain)
        v.register(cellType: UITableViewCell.self)
        v.dataSource = self
        v.delegate = self
        view.addSubview(v)
        return v
    }()
    
    var channels: [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MoyaNetwork.request(.channels) { [weak self] json in
            self?.channels = json["channels"].arrayValue
        } error: { statusCode in
            // 服务器报错等问题
            print("请求错误！错误码：\(statusCode)")
        } failure: { error in
            // 没有网络等问题
            print("请求失败！错误信息：\(error.errorDescription ?? "")")
        }
        
        // 需要上传的文件
        let file1URL = Bundle.main.url(forResource: "hangge", withExtension: "png")!
        // swiftlint: disable force_try
        let file1Data = try! Data(contentsOf: file1URL)
        let file2URL = Bundle.main.url(forResource: "2022", withExtension: "png")!
        // 通过Moya提交数据
        MoyaMyServiceProvider.request(
            .uploadFile0(value1: "hangge", value2: 10, file1Data: file1Data, file2URL: file2URL),
            progress: { progress in
                // 实时答打印出上传进度
                print("当前进度: \(progress.progress)")
            }, completion: { result in
                if case let .success(response) = result {
                    // 解析数据
                    let data = try? response.mapString()
                    print(data ?? "")
                }
            }
        )
    }
    
}

extension Moya2ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UITableViewCell.self)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = channels[indexPath.row]["name"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channelName = channels[indexPath.row]["name"].stringValue
        let channelId = channels[indexPath.row]["channel_id"].stringValue
        
        MoyaNetwork.request(.playlist(channelId)) { [weak self] json in
            let music = json["song"].arrayValue[0]
            let artist = music["artist"].stringValue
            let title = music["title"].stringValue
            let message = "歌手：\(artist)\n歌曲：\(title)"

            // 将歌曲信息弹出显示
            DispatchQueue.main.async {
                self?.showAlert(title: channelName, message: message)
            }
        } error: { statusCode in
            // 服务器报错等问题
            print("请求错误！错误码：\(statusCode)")
        } failure: { error in
            // 没有网络等问题
            print("请求失败！错误信息：\(error.errorDescription ?? "")")
        }

    }
}
