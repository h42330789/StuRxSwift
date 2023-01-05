//
//  RxFeedBack1ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import RxCocoa
import RxFeedback
import RxSwift
import UIKit

class RxFeedBack1ViewController: BaseViewController {
    var addBtn: UIButton!
    var reduceBtn: UIButton!
    var label: UILabel!
    lazy var textView: UITextView = {
        let v = UITextView(frame: CGRect(x: 100, y: 150, width: view.bounds.size.width - 200, height: 150))
        v.backgroundColor = .lightGray
        view.addSubview(v)
        return v
    }()

    struct StateModel {
        var id: Int // 数字
        var content: String // 当前id对应的内容
    }

    typealias State = StateModel
    enum Event {
        case increment // 加一
        case decrement // 减一
        case response(String) // 获取到的内容
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addBtn = createMyBtn(preView: nil, title: "+")
        label = {
            let label = UILabel(frame: CGRect(x: addBtn.frame.maxX, y: 100, width: 100, height: 40))
            label.textColor = .black
            label.text = "0"
            label.textAlignment = .center
            view.addSubview(label)
            return label
        }()
        reduceBtn = createMyBtn(preView: label, title: "-")

        // RxFeedback的核心方法
        Driver.system(
            // 初始状态
            initialState: StateModel(id: 0, content: ""),
            // 各个事件对状态的改变
            reduce: { state, event in
                switch event {
                case .increment:
                    var result = state
                    result.id += 1
                    return result
                case .decrement:
                    var result = state
                    result.id -= 1
                    return result
                case .response(let content):
                    var result = state
                    result.content = content
                    return result
                }
            },
            // UI反馈
            feedback: bind(self) { me, state -> Bindings<RxFeedBack1ViewController.Event> in
                // 状态输出到页面控件上
                let subscriptions = [
                    state.map { "\($0.id)" }.drive(me.label.rx.text),
                    state.map { "\($0.content)" }.drive(me.textView.rx.text)
                ]
                // 将UI事件变成Event输入到反馈循环里面去
                let events = [
                    me.addBtn.rx.tap.map { Event.increment },
                    me.reduceBtn.rx.tap.map { Event.decrement }
                ]
                return Bindings(subscriptions: subscriptions, events: events)
            },
            // 非UI的自动反馈
            react(request: { $0.id }, effects: { id in
                self.getContent(id: id)
                    .asSignal(onErrorRecover: { _ in .empty() })
                    .map(Event.response)
            })
        )
        .drive()
        .disposed(by: disposeBag)
    }

    func getContent(id: Int) -> Observable<String> {
        print("正在请求数据")
        return Observable.just("这是 id=\(id) 的新闻内容、。。")
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }

    func createMyBtn(preView: UIView?, title: String) -> UIButton {
        let x = preView?.frame.maxX ?? 100
        let addBtn = UIButton(frame: CGRect(x: x, y: 100, width: 40, height: 40))
        addBtn.setTitle(title, for: .normal)
        addBtn.backgroundColor = .blue
        addBtn.setTitleColor(.white, for: .normal)
        view.addSubview(addBtn)
        return addBtn
    }
}
