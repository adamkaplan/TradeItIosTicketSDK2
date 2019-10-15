import UIKit
import WebKit

class TradeItWebViewController: CloseableViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView?.navigationDelegate = self
        }
    }
    var url = ""
    var pageTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Loading...";
        guard let urlObject = URL (string: self.url) else {
            print("TradeIt SDK ERROR: Invalid url provided: " + self.url)
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        self.webView?.load(URLRequest(url: urlObject))
    }

    // MARK: WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = self.pageTitle;
    }
}
