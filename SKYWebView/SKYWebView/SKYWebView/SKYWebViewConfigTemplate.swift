import Foundation

/// WebView配置模板
struct SKYWebViewConfigTemplate {

    static var appName : String?
    static var defaultRequestHeaders : [String:String] = [:]
    private(set) static var jsDelegate : SKYWebViewJSDelegate = SKYWebViewJSDelegateImpl()
    private(set) static var naviDelegate : SKYWebViewNavigationDelegate = SKYWebViewNavigationDelegateImpl()
    private(set) static var uiConfig : SKYWebViewControllerUIConfig = SKYWebViewControllerUIConfig()

}
