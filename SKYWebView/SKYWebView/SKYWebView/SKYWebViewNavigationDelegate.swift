//
// Created by 梁天 on 2018/1/9.
// Copyright (c) 2018 com.lator. All rights reserved.
//

import UIKit
import WebKit

protocol SKYWebViewNavigationDelegate : NSCopying,WKNavigationDelegate {
    /// 导航时需要appOpenScheme的PrefixSet
    var navigationPrefixes : Set<String> {get}
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

class SKYWebViewNavigationDelegateImpl : NSObject,SKYWebViewNavigationDelegate {

    private(set) var navigationPrefixes: Set<String> = Set()
    var webViewDidStartProvisionalNavigationCallBack: (() -> Void)?
    var webViewDidFailNavigationCallBack: (() -> Void)?
    var webViewDidFinishNavigationCallBack: (() -> Void)?

    weak var bindViewController: UIViewController?
    weak var bindWebView: SKYWebView?

}

extension SKYWebViewNavigationDelegateImpl : NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newImpl = SKYWebViewNavigationDelegateImpl()
        newImpl.bindWebView = self.bindWebView
        newImpl.bindViewController = self.bindViewController
        newImpl.navigationPrefixes = self.navigationPrefixes
        newImpl.webViewDidStartProvisionalNavigationCallBack = self.webViewDidStartProvisionalNavigationCallBack
        newImpl.webViewDidFailNavigationCallBack = self.webViewDidFailNavigationCallBack
        newImpl.webViewDidFinishNavigationCallBack = self.webViewDidFinishNavigationCallBack

        return newImpl
    }
}

extension SKYWebViewNavigationDelegateImpl :WKNavigationDelegate {
    final func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let webViewDidStartProvisionalNavigationCallBack = webViewDidStartProvisionalNavigationCallBack {
            webViewDidStartProvisionalNavigationCallBack()
        }
    }

    final func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let webViewDidFailNavigationCallBack = webViewDidFailNavigationCallBack {
            webViewDidFailNavigationCallBack()
        }
    }

    final func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let webViewDidFinishNavigationCallBack = webViewDidFinishNavigationCallBack {
            webViewDidFinishNavigationCallBack()
        }
    }

    final func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let isHandled = decideNavigationActionPolicy(WithURL: url)

        if isHandled {
            decisionHandler(isHandled ? .cancel:.allow)
            return
        }

        if navigationAction.targetFrame != nil {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        guard let bindViewController = bindViewController {return}
        let webVC = SKYWebViewController()
        ///TODO:webvc load rq
        if let naviVC = bindViewController.navigationController {
            naviVC.pushViewController(webVC, animated: true)
        }else {
            let naviVC = UINavigationController(rootViewController: webVC)
            bindViewController.present(naviVC, animated: true, completion: nil)
        }
    }

    func decideNavigationActionPolicy(WithURL url: URL) -> Bool {
        let urlString = url.absoluteString
        for prefix in navigationPrefixes {
            guard urlString.hasPrefix(prefix) else {continue}
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            return true
        }
        return false
    }
}
