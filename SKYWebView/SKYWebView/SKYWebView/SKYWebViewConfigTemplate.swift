import Foundation

/// WebView配置模板
struct SKYWebViewConfigTemplate {

    static var appName : String?
    static let defaultRequestHeaders : [String:String] = [:]
    static let jsDelegate : SKYWebViewJSDelegate = SKYWebViewJSDelegateImpl()
    static let naviDelegate : SKYWebViewNavigationDelegate = SKYWebViewNavigationDelegateImpl()
    static let uiConfig : SKYWebViewControllerUIConfig = SKYWebViewControllerUIConfig()

}
