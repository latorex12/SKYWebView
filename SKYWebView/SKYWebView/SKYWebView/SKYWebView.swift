import Foundation
import WebKit

class SKYWebView : WKWebView {
    typealias ContentSizeChangedCallback = (CGSize)->Void
    var contentSizeChangedCallBack : ContentSizeChangedCallback?
    var httpRequestHeaders : [String:String]?
    var jsDelegate : SKYWebViewJSDelegate?
    var naviDelegate : SKYWebViewNavigationDelegate?
 
    convenience init(with jsDelegate:SKYWebViewJSDelegate? = SKYWebViewJSDelegateImpl() ,and naviDelegate:SKYWebViewNavigationDelegate? = SKYWebViewNavigationDelegateImpl()) {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        self.init(frame: CGRect.zero, configuration: config)
    }
}
