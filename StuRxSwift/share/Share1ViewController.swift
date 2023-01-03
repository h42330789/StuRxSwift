//
//  Share1ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import UIKit
import RxSwift
import RxCocoa

class Share1ViewController: UIViewController {

    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let pub = PublishSubject<Int>()
        let pub2 = pub.map {
            print("mapA->\($0)")
            return $0*2
        }
        
//        let pub3 = pub2.map{
//            print("mapB->\($0)")
//            return "mapx--\($0)"
//        }
        let pub3 = pub2.flatMap { _ in
            print("flatMap--1")
            return Observable.just("MM").map { _ in
                print("mm-map")
                return "RR"
            }
        }
        
        let pub4 = pub3.map {
            print("mapC->\($0)")
            return "mapy--\($0)"
        }.share(replay: 1)
            // .share(replay: 1)
        
        pub4.subscribe(onNext: {
            print("subA--\($0)")
        }).disposed(by: disposeBag)
        pub4.subscribe(onNext: {
            print("subB--\($0)")
        }).disposed(by: disposeBag)
        
        pub.onNext(1)
    }

}
