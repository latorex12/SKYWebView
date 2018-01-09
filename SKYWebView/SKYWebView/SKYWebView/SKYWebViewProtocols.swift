import UIKit
import WebKit

protocol Copyable {
    func copy() -> Self
}

protocol SKYWebViewControllerUIConfigDelegate {
    /// 是否显示加载HUD
    var showLoading : Bool {get set}
    /// 是否显示进度条
    var showProgress : Bool {get set}
    /// 默认标题
    var fixedTitle : String? {get set}
    /// 返回按钮图片,可空，默认为返回文字
    var backBarButtonImage : UIImage? {get set}
    /// 关闭按钮图片，可空，默认为关闭文字
    var closeBarButtonImage : UIImage? {get set}
    /// 进度条颜色
    var progressTintColor : UIColor? {get set}
    /// 进度条背景色
    var trackTintColor : UIColor? {get set}
}

protocol SKYWebViewJSDelegate : Copyable,WKScriptMessageHandler {
    
    /// 注入的userScript集合
    var injectScriptNames : Set<String> {get}
    /// 注入的scriptMsgHandlerNames集合，是内部handleBlock字典的keys
    var userScripts : Set<WKUserScript> {get}
    /// 绑定的代理vc
    weak var bindViewController : UIViewController? {get set}
    /// 绑定的代理webView
    weak var bindWebView : SKYWebView? {get set}
    
}

protocol SKYWebViewNavigationDelegate : Copyable,WKNavigationDelegate {
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
