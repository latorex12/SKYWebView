//
// Created by 梁天 on 2018/1/9.
// Copyright (c) 2018 com.lator. All rights reserved.
//

import UIKit
import WebKit

protocol SKYWebViewNavigationDelegate : NSCopying,WKNavigationDelegate {
    /// webView开始加载回调
    var webViewDidStartProvisionalNavigationCallBack : (()->Void)? {get}
    /// webView加载失败回调
    var webViewDidFailNavigationCallBack : (()->Void)? {get}
    /// webView加载成功回调
    var webViewDidFinishNavigationCallBack : (()->Void)? {get}
    /// 绑定的代理vc
    weak var bindViewController : UIViewController? {get set}
    /// 绑定的代理webView
    weak var bindWebView : SKYWebView? {get set}
}

struct SKYWebViewNavigationDelegateImpl : SKYWebViewNavigationDelegate {

}
