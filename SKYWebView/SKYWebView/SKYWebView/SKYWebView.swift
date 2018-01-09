import Foundation
import WebKit

class SKYWebView : WKWebView {
    typealias ContentSizeChangedCallback = (CGSize)->Void
    
    var contentSizeChangedCallBack : ContentSizeChangedCallback?
    var httpRequestHeaders : [String:String]?
    var jsDelegate : SKYWebViewJSDelegate?
    var naviDelegate : SKYWebViewNavigationDelegate?

    private(set) var requestURL: URL?
    private(set) var timeoutInterval: TimeInterval = 30
    
    deinit {
        ///TODO:deinit
    }
    
    init(withJSDelegate jsDelegate:SKYWebViewJSDelegate? = SKYWebViewConfigTemplate.jsDelegate.copy() ,andNaviDelegate naviDelegate:SKYWebViewNavigationDelegate? = SKYWebViewConfigTemplate.naviDelegate.copy()) {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        config.userContentController = userContentController
        
        super.init(frame: .zero, configuration: config)
        
        self.jsDelegate = jsDelegate
        self.naviDelegate = naviDelegate
    }
    
    convenience init() {
        self.init(withJSDelegate: SKYWebViewConfigTemplate.jsDelegate.copy(), andNaviDelegate: SKYWebViewConfigTemplate.naviDelegate.copy())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadRequest(withURL url: inout URL, timeoutInterval interval: TimeInterval = 30) {
        if url.scheme == nil {
            let urlStringWithScheme = "http://" + url.absoluteString
            url = URL.init(string: urlStringWithScheme)!
        }
        timeoutInterval = interval
        
        
    }
    
    func reloadRequest() {
        
    }
    
    func removeScripts() {
        
    }
}

