import Foundation

struct SKYWebViewConfigTemplate {

    static var appName : String?
    static let defaultRequestHeaders : [String:String] = [:]
    static let jsDelegate : SKYWebViewJSDelegate = SKYWebViewJSDelegateImpl()
    static let naviDelegate : SKYWebViewNavigationDelegate = SKYWebViewNavigationDelegateImpl()
    static let uiConfig : SKYWebViewControllerUIConfig = SKYWebViewControllerUIConfig()

}
