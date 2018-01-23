import UIKit
import WebKit

open class SKYWebViewJSDelegateImpl : NSObject,SKYWebViewJSDelegate {
    /// HBWebView的JS代理具体实现
    public typealias SKYWebViewScriptHandleCallBack = (Any)->Void

    open var injectScriptNames: Set<String> {
        get {
            return Set(scriptHandleDict.keys)
        }
    }
    private(set) public var userScripts: Set<WKUserScript> = Set()
    open weak var bindViewController: UIViewController?
    open weak var bindWebView: SKYWebView?

    private var scriptHandleDict : [String:SKYWebViewScriptHandleCallBack] = [:]

    public final func addUserScripts(scripts: Set<WKUserScript>) {
        userScripts.formUnion(scripts)

        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        scripts.forEach({ (script) in
            userContentController.addUserScript(script)
        })
    }

    public final func addScriptName(name: String, handler:@escaping SKYWebViewScriptHandleCallBack) {
        scriptHandleDict[name] = handler

        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.add(self, name: name)
    }

    public final func removeScriptHandler(forName name: String) {
        scriptHandleDict[name] = nil
        
        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.removeScriptMessageHandler(forName: name)
    }

    public final func removeAllScripts() {
        scriptHandleDict.removeAll()
        
        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.removeAllUserScripts()
    }

    required override public init() {super.init()}
}


//MARK:- Copyable
extension SKYWebViewJSDelegateImpl : Copyable {
    public func copy() -> Self {
        let newImpl = type(of: self).init()
        newImpl.bindWebView = self.bindWebView
        newImpl.bindViewController = self.bindViewController
        newImpl.userScripts = self.userScripts
        newImpl.scriptHandleDict = self.scriptHandleDict
        return newImpl
    }
}


//MARK:- WKScriptMessageHandler
extension SKYWebViewJSDelegateImpl : WKScriptMessageHandler {
    final public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
