//
//  ViewController+Rx.swift
//  StuRxSwift
//
//  Created by abc on 12/20/22.
//

import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {

    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in}
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear))
            .map { $0.first as? Bool ?? false}
        return ControlEvent(events: source)
    }
}
