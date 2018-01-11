import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
    super.viewDidLoad()
        
        
    
    }
    
    @IBAction func presentWebView(_ sender: Any) {
        let webVC = SKYWebViewController()
        let naviVC = UINavigationController(rootViewController: webVC)
        present(naviVC, animated: true, completion: nil)
        
        // test url with no scheme
        webVC.loadRequestWithURL(url: URL.init(string: "www.baidu.com")!)
    }

}
