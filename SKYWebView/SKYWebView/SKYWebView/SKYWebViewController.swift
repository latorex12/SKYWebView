import UIKit
import WebKit
import MBProgressHUD

public final class SKYWebViewControllerUIConfig : SKYWebViewControllerUIConfigDelegate {
    public var showLoading: Bool = false
    public var showProgress: Bool = true
    public var fixedTitle: String?
    public var backBarButtonImage: UIImage?
    public var backBarButtonCustomView: UIView?
    public var closeBarButtonImage: UIImage?
    public var closeBarButtonCustomView: UIView?
    /// iOS11实测，低于8无效
    public var itemFixedSpace: CGFloat?
    public var progressTintColor: UIColor?
    public var trackTintColor: UIColor?
}


//MARK: Copyable
extension SKYWebViewControllerUIConfig : Copyable {
    public func copy() -> SKYWebViewControllerUIConfig {
        let newConfig = SKYWebViewControllerUIConfig()
        newConfig.showLoading = self.showLoading
        newConfig.showProgress = self.showProgress
        newConfig.fixedTitle = self.fixedTitle
        newConfig.backBarButtonImage = self.backBarButtonImage
        newConfig.backBarButtonCustomView = self.backBarButtonCustomView?.copy()
        newConfig.closeBarButtonImage = self.closeBarButtonImage
        newConfig.closeBarButtonCustomView = self.closeBarButtonCustomView?.copy()
        newConfig.itemFixedSpace = self.itemFixedSpace
        newConfig.progressTintColor = self.progressTintColor
        newConfig.trackTintColor = self.trackTintColor
        return newConfig
    }
}

//MARK:-
open class SKYWebViewController : UIViewController {
    
    deinit {
        webView.removeScripts()
        removeObserver()
    }

    public init(withConfig config: SKYWebViewControllerUIConfig?) {
        super.init(nibName: nil, bundle: nil)
        let config = config ?? SKYWebViewConfigTemplate.uiConfig.copy()
        self.config = config
        setupObserver()
    }
    
    public convenience init() {
        self.init(withConfig: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func loadRequestWithURL(url: URL) {
        webView.loadRequest(withURL: url)
    }
    
    @objc open func reloadRequest() {
        webView.reloadRequest()
    }
    
    @objc private(set) lazy var webView : SKYWebView = {
        let webView = SKYWebView()
        webView.jsDelegate?.bindViewController = self
        webView.naviDelegate?.bindViewController = self
        webView.naviDelegate?.webViewDidStartProvisionalNavigationCallBack = {
            [weak self] in
            self?.webViewDidStartProvisionalNavigation()
        }
        webView.naviDelegate?.webViewDidFailNavigationCallBack = {
            [weak self] in
            self?.webViewDidFailNavigation()
        }
        webView.naviDelegate?.webViewDidFinishNavigationCallBack = {
            [weak self] in
            self?.webViewDidFinishNavigation()
        }
        return webView
    }()
    private(set) lazy var progressView : UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = self.config.progressTintColor
        progressView.trackTintColor = self.config.trackTintColor
        progressView.alpha = self.config.showProgress ? 1:0
        return progressView
    }()
    private(set) var config : SKYWebViewControllerUIConfig!
    private lazy var refreshControl : UIRefreshControl = {
        let control = UIRefreshControl()
        return control
    }()
    private lazy var backBarButtonItem : UIBarButtonItem = {
        if let customView = self.config.backBarButtonCustomView {
            let item = UIBarButtonItem(customView: customView)
            ///TODO:selector
            let tap = UITapGestureRecognizer(target: self, action: #selector(goBack))
            customView.addGestureRecognizer(tap)
            return item
        }
        else {
            let button = UIButton(type: .custom)
            button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
            if let backButtonImg = self.config.backBarButtonImage ?? self.navigationController?.navigationBar.backIndicatorImage {
                button.setImage(backButtonImg, for: .normal)
            }
            else {
                button.setTitle("返回", for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                button.titleLabel?.textAlignment = .right
            }
            button.sizeToFit()
            let item = UIBarButtonItem(customView: button)
            return item
        }
    }()
    private lazy var spaceBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = config.itemFixedSpace ?? 0
        return item
    }()
    private lazy var closeBarButtonItem : UIBarButtonItem = {
        if let customView = self.config.closeBarButtonCustomView {
            let item = UIBarButtonItem(customView: customView)
            ///TODO:selector
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
            customView.addGestureRecognizer(tap)
            return item
        }
        else {
            let button = UIButton(type: .custom)
            button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
            if let closeButtonImg = self.config.closeBarButtonImage {
                button.setImage(closeButtonImg, for: .normal)
            }
            else {
                button.setTitle("关闭", for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                button.titleLabel?.textAlignment = .right
            }
            button.sizeToFit()
            let item = UIBarButtonItem(customView: button)
            return item
        }
    }()
    private lazy var progressHUD : MBProgressHUD = {
        let hud = MBProgressHUD(view: self.view)
        self.view.addSubview(hud)
        return hud
    }()
}

//MARK:-Lift Cycle
extension SKYWebViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override open func viewDidLayoutSubviews() {
        progressView.frame = CGRect(x: 0, y: navigationController?.navigationBar.frame.size.height ?? 0, width: view.frame.size.width, height: 3)
        webView.frame = view.frame
    }
}


//MARK:- UI
extension SKYWebViewController {
    func setupViews() {
        navigationItem.title = config.fixedTitle
        
        refreshControl.addTarget(self, action: #selector(reloadRequest), for: .valueChanged)
        
        (navigationController?.navigationBar ?? view)?.addSubview(progressView)
        view.addSubview(webView)
        webView.scrollView.addSubview(refreshControl)
        
        setupCustomBarButtonItems()
    }
    
    func setupCustomBarButtonItems() {
        self.navigationItem.leftBarButtonItems = webView.canGoBack ? [backBarButtonItem,spaceBarButtonItem,closeBarButtonItem]:[backBarButtonItem]
    }
    func startLoading() {
        if config.showLoading {
            progressHUD.show(animated: true)
        }
    }
    
    func endLoading() {
        if config.showLoading {
            progressHUD.hide(animated: true)
        }
    }
    
    func showHUDWithMessage(message: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.offset.y = -100
        hud.mode = .text
        hud.label.text = message
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: 1.5)
    }
}


//MARK:- Actions
extension SKYWebViewController {
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
        else {
            dismissVC()
        }
    }
    
    @objc func dismissVC() {
        progressView.removeFromSuperview()
        
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        else if let navigationController = navigationController {
            if navigationController.viewControllers.first!.isEqual(self) {
                navigationController.dismiss(animated: true, completion: nil)
            }
            else {
                navigationController.popViewController(animated: true)
            }
        }
    }
}


//MARK:- Observer
extension SKYWebViewController {
    func setupObserver() {
        self.addObserver(self, forKeyPath: #keyPath(webView.title), options: [.new], context: nil)
        self.addObserver(self, forKeyPath: #keyPath(webView.estimatedProgress), options: [.new], context: nil)
        self.addObserver(self, forKeyPath: #keyPath(webView.canGoBack), options: [.new], context: nil)
    }
    
    func removeObserver() {
        self.removeObserver(self, forKeyPath: #keyPath(webView.title))
        self.removeObserver(self, forKeyPath: #keyPath(webView.estimatedProgress))
        self.removeObserver(self, forKeyPath: #keyPath(webView.canGoBack))
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath! {
        case #keyPath(webView.title):
            guard config.fixedTitle != nil,
                let newTitle = change![.newKey] as? String
                else {return}
            
                navigationItem.title = newTitle
            break
        case #keyPath(webView.estimatedProgress):
            let progress = change![.newKey] as! Float
            progressView.progress = progress
            progressView.isHidden = progress == 1 ? true:false
            break
        case #keyPath(webView.canGoBack):
            setupCustomBarButtonItems()
            break
        default:
            break
        }
    }
}


//MARK:- Navigation Delegate
extension SKYWebViewController {
    func webViewDidStartProvisionalNavigation() {
        startLoading()
        
        if config.fixedTitle == nil {
            self.navigationItem.title = "加载中..."
        }
    }

    func webViewDidFailNavigation() {
        refreshControl.endRefreshing()
        self.endLoading()
        showHUDWithMessage(message: "加载失败")
    }

    func webViewDidFinishNavigation() {
        view.setNeedsDisplay()
        refreshControl.endRefreshing()
        self.endLoading()
        
        if config.fixedTitle == nil {
            navigationItem.title = webView.title
        }
    }
}

