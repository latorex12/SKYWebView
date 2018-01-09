import UIKit
import WebKit

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

    final func addUserScripts(scripts: Set<WKUserScript>) {
        userScripts.formUnion(scripts)

        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        for script in scripts {
            userContentController.addUserScript(script)
        }
    }

    final func addScriptName(name: String, handler:@escaping SKYWebViewScriptHandleCallBack) {
        scriptHandleDict[name] = handler

        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.add(self, name: name)
    }

    final func removeScriptHandler(forName name: String) {
        scriptHandleDict[name] = nil
        
        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.removeScriptMessageHandler(forName: name)
    }

    final func removeAllScripts() {
        scriptHandleDict.removeAll()
        
        guard let userContentController = bindWebView?.configuration.userContentController else {return}
        
        userContentController.removeAllUserScripts()
    }

    required override init() {super.init()}
}

extension SKYWebViewJSDelegateImpl : Copyable {
    func copy() -> Self {
        let newImpl = type(of: self).init()
        newImpl.bindWebView = self.bindWebView
        newImpl.bindViewController = self.bindViewController
        newImpl.userScripts = self.userScripts
        newImpl.scriptHandleDict = self.scriptHandleDict
        return newImpl
    }
}

extension SKYWebViewJSDelegateImpl : WKScriptMessageHandler {
    final func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
