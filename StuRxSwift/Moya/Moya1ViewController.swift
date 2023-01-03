//
//  Moya1ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import UIKit
import SwiftyJSON
import Reusable

class Moya1ViewController: BaseViewController {
    
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
        
        DouBanProvider.request(.channels) {[weak self] result in
            if case let .success(response) = result {
                // 解析数据
                let data = try? response.mapJSON()
                let json = JSON(data!)
                self?.channels = json["channels"].arrayValue

                // 刷新表格数据
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }

    }
    
}

extension Moya1ViewController: UITableViewDataSource, UITableViewDelegate {
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
        
        DouBanProvider.request(.playlist(channelId)) {[weak self] result in
            if case let .success(response) = result {
                // 解析数据
                let data = try? response.mapJSON()
                let json = JSON(data!)
                let music = json["song"].arrayValue[0]
                let artist = music["artist"].stringValue
                let title = music["title"].stringValue
                let message = "歌手：\(artist)\n歌曲：\(title)"

                // 将歌曲信息弹出显示
                DispatchQueue.main.async {
                    self?.showAlert(title: channelName, message: message)
                }
            }
        }
        
    }
}
