import Foundation
import WebKit

class SKYWebView : WKWebView {
    typealias RequestWillLoadCallack = (inout URLRequest)->Void
    typealias ContentSizeChangedCallback = (CGSize)->Void

    var requestWillLoadCallack : RequestWillLoadCallack?
    var contentSizeChangedCallBack : ContentSizeChangedCallback?
    var httpRequestHeaders : [String:String]?
    var jsDelegate : SKYWebViewJSDelegate? {
        willSet {
            let userContentController = configuration.userContentController
            
            userContentController.removeAllUserScripts()
            if let jsDelegate = jsDelegate {
                for name in jsDelegate.injectScriptNames {
                    userContentController.removeScriptMessageHandler(forName: name)
                }
            }
            
            if let newValue = newValue {
                newValue.bindWebView = self
                for name in newValue.injectScriptNames {
                    userContentController.add(newValue, name: name)
                }
                for scripts in newValue.userScripts {
                    userContentController.addUserScript(scripts)
                }
            }
        }
    }
    var naviDelegate : SKYWebViewNavigationDelegate? {
        willSet {
            navigationDelegate = newValue
            if let newValue = newValue {
                newValue.bindWebView = self
            }
        }
    }

    private(set) var requestURL: URL?
    private(set) var timeoutInterval: TimeInterval = 30

    deinit {
        removeScripts()
        removeObserver()
    }
    
    init(withJSDelegate jsDelegate:SKYWebViewJSDelegate? = SKYWebViewConfigTemplate.jsDelegate.copy() ,andNaviDelegate naviDelegate:SKYWebViewNavigationDelegate? = SKYWebViewConfigTemplate.naviDelegate.copy()) {
        let config = WKWebViewConfiguration()
        if #available(iOS 9.0,*),
           let appName = SKYWebViewConfigTemplate.appName {
            config.applicationNameForUserAgent = appName
        }

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
    
    func loadRequest(withURL url: URL, timeoutInterval interval: TimeInterval = 30) {
        var tempURL = url
        if tempURL.scheme == nil {
            let urlStringWithScheme = "http://" + tempURL.absoluteString
            tempURL = URL.init(string: urlStringWithScheme)!
        }
        timeoutInterval = interval > 0 ? interval:30

        var request = URLRequest(url: tempURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)

        func setHeaderDict(dict: [String:String]?, forRequest request: inout URLRequest) {
            guard let dict = dict else {return}
            for (key,value) in dict {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        setHeaderDict(dict: SKYWebViewConfigTemplate.defaultRequestHeaders, forRequest: &request)
        setHeaderDict(dict: httpRequestHeaders, forRequest: &request)

        requestWillLoadCallack?(&request)

        self.load(request)
    }
    
    func reloadRequest() {
        loadRequest(withURL: requestURL!, timeoutInterval: timeoutInterval)
    }
    
    func removeScripts() {
        guard let jsDelegate = jsDelegate else {return}
        jsDelegate.bindWebView = nil
        self.jsDelegate = nil
    }
}

/// Observe
extension SKYWebView {
    func setupObserver() {
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.old], context: nil)
    }

    func removeObserver() {
        scrollView.removeObserver(self, forKeyPath: "contentSize")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            let oldSize = change![NSKeyValueChangeKey.oldKey] as! CGSize
            let newSize = self.scrollView.contentSize
            
            if oldSize == newSize,let callback = contentSizeChangedCallBack {
                callback(newSize)
            }
        }
    }
}

