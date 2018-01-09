import UIKit
import WebKit

protocol SKYWebViewJSDelegate : NSCopying,WKScriptMessageHandler {

    /// 注入的userScript集合
    var injectScriptNames : Set<String> {get}
    /// 注入的scriptMsgHandlerNames集合，是内部handleBlock字典的keys
    var userScripts : Set<WKUserScript> {get}
    /// 绑定的代理vc
    weak var bindViewController : UIViewController? {get set}
    /// 绑定的代理webView
    weak var bindWebView : SKYWebView? {get set}

}

class SKYWebViewJSDelegateImpl : NSObject,SKYWebViewJSDelegate {
    /// HBWebView的JS代理具体实现
    typealias SKYWebViewScriptHandleCallBack = (Any)->Void

    var injectScriptNames: Set<String> {
        get {
            return Set(scriptHandleDict.keys)
        }
    }
    private(set) var userScripts: Set<WKUserScript> = Set()
    weak var bindViewController: UIViewController?
    weak var bindWebView: SKYWebView?

    private var scriptHandleDict : [String:SKYWebViewScriptHandleCallBack] = [:]

    func addUserScripts(scripts: Set<WKUserScript>) {
        userScripts.formUnion(scripts)

        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        for script in scripts {
            userContentController.addUserScript(script)
        }
    }

    func addScriptName(name: String, handler:@escaping SKYWebViewScriptHandleCallBack) {
        scriptHandleDict[name] = handler

        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.add(self, name: name)
    }
    
    func removeScriptHandler(forName name: String) {
        scriptHandleDict[name] = nil
        
        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.removeScriptMessageHandler(forName: name)
    }
    
    func removeAllScripts() {
        scriptHandleDict.removeAll()
        
        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.removeAllUserScripts()
    }

}

extension SKYWebViewJSDelegateImpl : NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newImpl = SKYWebViewJSDelegateImpl()
        newImpl.bindWebView = self.bindWebView
        newImpl.bindViewController = self.bindViewController
        newImpl.userScripts = self.userScripts
        newImpl.scriptHandleDict = self.scriptHandleDict
        return newImpl
    }
}

extension SKYWebViewJSDelegateImpl : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let name = message.name
        let info = message.body
        
        let _ = self.handleScript(withName: name, info: info)
    }
    
    func handleScript(withName name: String, info: Any) -> Bool {
        guard let handler = scriptHandleDict[name] else { return false }
        
        handler(info)
        return true
    }
}
