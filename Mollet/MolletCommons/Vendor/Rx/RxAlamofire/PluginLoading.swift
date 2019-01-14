//
//  PluginLoading.swift
//  Mollet
//
//  Created by Mr.zhang on 2018/10/12.
//  Copyright © 2018年 Mr.zhang. All rights reserved.
//
// Observable 插件

import Foundation
import RxSwift

extension Observable {
    
    func loadingPlugin() -> Observable<Element> {
        //doOn 监听Observable的生命周期
        return self.do(onNext:{ _ in
            ReachabilityManager.netWorkCheck()
            MBProgressHUDSwift.showLoading()
        }, onError: { error in
            print("出错了！")
            MBProgressHUDSwift.dismiss()
        }, onCompleted: {
            //onNext没调用onCompleted ，这里就不会执行
            MBProgressHUDSwift.dismiss()
        },onDispose: {
            print("Intercepted Disposed")
        })
    }
}
