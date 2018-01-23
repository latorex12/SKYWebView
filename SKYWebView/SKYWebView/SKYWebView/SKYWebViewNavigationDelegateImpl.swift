import UIKit
import WebKit

class SKYWebViewNavigationDelegateImpl : NSObject,SKYWebViewNavigationDelegate {

    var navigationPrefixes: Set<String> = Set()
    var webViewDidStartProvisionalNavigationCallBack: (() -> Void)?
    var webViewDidFailNavigationCallBack: (() -> Void)?
    var webViewDidFinishNavigationCallBack: (() -> Void)?

    weak var bindViewController: UIViewController?
    weak var bindWebView: SKYWebView?

    required override init() {super.init()}
}


//MARK:- Copyable
extension SKYWebViewNavigationDelegateImpl : Copyable {
    func copy() -> Self {
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

    func decideNavigationActionPolicy(WithURL url: URL) -> Bool {
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
