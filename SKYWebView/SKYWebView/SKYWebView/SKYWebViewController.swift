import UIKit
import WebKit

struct SKYWebViewControllerUIConfig : SKYWebViewControllerUIConfigDelegate {
    var showLoading: Bool = false
    var showProgress: Bool = true
    var fixedTitle: String?
    var backBarButtonImage: UIImage?
    var closeBarButtonImage: UIImage?
    var progressTintColor: UIColor?
    var trackTintColor: UIColor?
}


class SKYWebViewController : UIViewController {
    var v:SKYWebView = SKYWebView(andNaviDelegate: nil)
}
