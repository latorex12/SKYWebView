import UIKit
import WebKit

open class SKYWebViewNavigationDelegateImpl : NSObject,SKYWebViewNavigationDelegate {

    open var navigationPrefixes: Set<String> = Set()
    open var webViewDidStartProvisionalNavigationCallBack: (() -> Void)?
    open var webViewDidFailNavigationCallBack: (() -> Void)?
    open var webViewDidFinishNavigationCallBack: (() -> Void)?

    open weak var bindViewController: UIViewController?
    open weak var bindWebView: SKYWebView?

    required override public init() {super.init()}
}


//MARK:- Copyable
extension SKYWebViewNavigationDelegateImpl : Copyable {
    public func copy() -> Self {
        let newImpl = type(of: self).init()
        newImpl.bindWebView = self.bindWebView
        newImpl.bindViewController = self.bindViewController
        newImpl.navigationPrefixes = self.navigationPrefixes
        newImpl.webViewDidStartProvisionalNavigationCallBack = self.webViewDidStartProvisionalNavigationCallBack
        newImpl.webViewDidFailNavigationCallBack = self.webViewDidFailNavigationCallBack
        newImpl.webViewDidFinishNavigationCallBack = self.webViewDidFinishNavigationCallBack

        return newImpl
    }
}


//MARK:- WKNavigationDelegate
extension SKYWebViewNavigationDelegateImpl : WKNavigationDelegate {
    final public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let webViewDidStartProvisionalNavigationCallBack = webViewDidStartProvisionalNavigationCallBack {
            webViewDidStartProvisionalNavigationCallBack()
        }
    }

    final public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let webViewDidFailNavigationCallBack = webViewDidFailNavigationCallBack {
            webViewDidFailNavigationCallBack()
        }
    }

    final public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let webViewDidFinishNavigationCallBack = webViewDidFinishNavigationCallBack {
            webViewDidFinishNavigationCallBack()
        }
    }

    final public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let isHandled = decideNavigationActionPolicy(WithURL: url)

        guard !isHandled else {
            decisionHandler(isHandled ? .cancel:.allow)
            return
        }

        guard navigationAction.targetFrame == nil else {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        guard let bindViewController = bindViewController else {return}
        let webVC = SKYWebViewController()
        ///TODO:webvc load rq
        if let naviVC = bindViewController.navigationController {
            naviVC.pushViewController(webVC, animated: true)
        }else {
            let naviVC = UINavigationController(rootViewController: webVC)
            bindViewController.present(naviVC, animated: true, completion: nil)
        }
    }

    open func decideNavigationActionPolicy(WithURL url: URL) -> Bool {
        let urlString = url.absoluteString
        
        let containDefinedPrefix = navigationPrefixes.contains { (prefix) -> Bool in
            return urlString.hasPrefix(prefix)
        }
        guard containDefinedPrefix else { return false }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
        return true
    }
}
