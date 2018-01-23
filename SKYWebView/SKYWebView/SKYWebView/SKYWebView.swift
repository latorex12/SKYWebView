import Foundation
import WebKit

open class SKYWebView : WKWebView {
    public typealias RequestWillLoadCallack = (inout URLRequest)->Void
    public typealias ContentSizeChangedCallback = (CGSize)->Void

    deinit {
        removeScripts()
        removeObserver()
    }
    
    public init(withJSDelegate jsDelegate: SKYWebViewJSDelegate?,andNaviDelegate naviDelegate:SKYWebViewNavigationDelegate?) {
        let config = WKWebViewConfiguration()
        if #available(iOS 9.0,*),
           let appName = SKYWebViewConfigTemplate.appName {
            config.applicationNameForUserAgent = appName
        }

        super.init(frame: .zero, configuration: config)
        
        self.setupObserver()
        /// 属性观察方法在init中不调用，所以使用setter方法
        self.willSetJSDelegate(jsDelegate)
        self.jsDelegate = jsDelegate
        self.willSetNaviDelegate(naviDelegate)
        self.naviDelegate = naviDelegate
    }
    
    public convenience init() {
        self.init(withJSDelegate: SKYWebViewConfigTemplate.jsDelegate.copy(), andNaviDelegate: SKYWebViewConfigTemplate.naviDelegate.copy())
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func loadRequest(withURL url: URL, timeoutInterval interval: TimeInterval = 30) {
        var tempURL = url
        if tempURL.scheme == nil {
            let urlStringWithScheme = "http://" + tempURL.absoluteString
            tempURL = URL.init(string: urlStringWithScheme)!
        }
        requestURL = tempURL
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
    
    open func reloadRequest() {
        guard let requestURL = requestURL else {return}
        loadRequest(withURL: requestURL, timeoutInterval: timeoutInterval)
    }
    
    open func removeScripts() {
        guard let jsDelegate = jsDelegate else {return}
        jsDelegate.bindWebView = nil
        self.jsDelegate = nil
    }
    
    open var requestWillLoadCallack : RequestWillLoadCallack?
    open var contentSizeChangedCallBack : ContentSizeChangedCallback?
    open var httpRequestHeaders : [String:String]?
    public var jsDelegate : SKYWebViewJSDelegate? {
        willSet {
            willSetJSDelegate(newValue)
        }
    }
    public var naviDelegate : SKYWebViewNavigationDelegate? {
        willSet {
            willSetNaviDelegate(newValue)
        }
    }
    
    private(set) var requestURL: URL?
    private(set) var timeoutInterval: TimeInterval = 30
}


//MARK:- Setter
extension SKYWebView {
    func willSetJSDelegate(_ newValue: SKYWebViewJSDelegate?) {
        let userContentController = configuration.userContentController
        
        userContentController.removeAllUserScripts()
        if let oldValue = self.jsDelegate {
            oldValue.injectScriptNames.forEach({ (name) in
                userContentController.removeScriptMessageHandler(forName: name)
            })
        }
        
        if let newValue = newValue {
            newValue.bindWebView = self
            newValue.injectScriptNames.forEach({ (name) in
                userContentController.add(newValue, name: name)
            })
            newValue.userScripts.forEach({ (script) in
                userContentController.addUserScript(script)
            })
        }
    }
    
    func willSetNaviDelegate(_ newValue: SKYWebViewNavigationDelegate?) {
        navigationDelegate = newValue
        newValue?.bindWebView = self
    }
}


//MARK:- Observe
extension SKYWebView {
    func setupObserver() {
        self.addObserver(self, forKeyPath: #keyPath(scrollView.contentSize), options: [.old], context: nil)
    }

    func removeObserver() {
        self.removeObserver(self, forKeyPath: #keyPath(scrollView.contentSize))
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(scrollView.contentSize) {
            let oldSize = change![NSKeyValueChangeKey.oldKey] as! CGSize
            let newSize = self.scrollView.contentSize
            
            if oldSize == newSize,let callback = contentSizeChangedCallBack {
                callback(newSize)
            }
        }
    }
}

