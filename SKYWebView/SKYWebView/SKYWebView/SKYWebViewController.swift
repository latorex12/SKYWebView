import UIKit
import WebKit

struct SKYWebViewControllerUIConfig : SKYWebViewControllerUIConfigDelegate {
    var showLoading: Bool = false
    var showProgress: Bool = true
    var fixedTitle: String?
    var backBarButtonImage: UIImage?
    var backBarButtonCustomView: UIView?
    var closeBarButtonImage: UIImage?
    var progressTintColor: UIColor?
    var trackTintColor: UIColor?
}

extension SKYWebViewControllerUIConfig : Copyable {
    func copy() -> SKYWebViewControllerUIConfig {
        var newConfig = self
        newConfig.backBarButtonCustomView = self.backBarButtonCustomView?.copy()
        return newConfig
    }
}


class SKYWebViewController : UIViewController {

    private(set) lazy var webView : SKYWebView = {
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
    private(set) lazy var processView : UIProgressView = {
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
        return item
    }()
    private lazy var closeBarButtonItem : UIBarButtonItem = {
        let item = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(dismissVC))
        return item
    }()
    
    deinit {
        webView.removeScripts()
        removeObserver()
    }

    init(withConfig config: SKYWebViewControllerUIConfig?) {
        super.init(nibName: nil, bundle: nil)
        let config = config ?? SKYWebViewConfigTemplate.uiConfig.copy()
        self.config = config
    }
    
    convenience init() {
        self.init(withConfig: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        processView.frame = CGRect(x: 0, y: navigationController?.navigationBar.frame.size.height ?? 0, width: view.frame.size.width, height: 3)
        webView.frame = view.frame
    }
    
    func setupViews() {
        navigationItem.title = config.fixedTitle
        
        refreshControl.addTarget(self, action: #selector(reloadRequest), for: .valueChanged)
        
        (navigationController?.navigationBar ?? view)?.addSubview(processView)
        view.addSubview(webView)
        webView.scrollView.addSubview(refreshControl)
        
        setupCustomBarButtonItems()
    }
    
    func setupCustomBarButtonItems() {
        self.navigationItem.leftBarButtonItems = webView.canGoBack ? [backBarButtonItem,spaceBarButtonItem,closeBarButtonItem]:[backBarButtonItem]
    }
    
    func setupObserver() {
        
    }
    
    func removeObserver() {
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
    
    @objc func goBack() {
        
    }
    
    @objc func dismissVC() {
        
    }
    
    func loadRequestWithURL(url: URL) {
        webView.loadRequest(withURL: url)
    }
    
    @objc func reloadRequest() {
        webView.reloadRequest()
    }
    
    func startLoading() {
        
    }
    
    func endLoading() {
        
    }
}

/// Navigation Delegate
extension SKYWebViewController {
    
    func webViewDidStartProvisionalNavigation() {

    }

    func webViewDidFailNavigation() {

    }

    func webViewDidFinishNavigation() {

    }
}
