import UIKit
import SafariServices
import WebKit

final class WebViewViewController: UIViewController {
    var urlString: String?
    var browserType: BrowserType?
    
    private let webview = WKWebView()
    private var safariViewController: SFSafariViewController!
    
    @IBOutlet weak var indicateType: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callBrowser()
    }
    
    private func callBrowser() {
        guard let browserType = browserType else {
            debugPrint("-->> Browser type is null")
            return
        }
        
        self.setIndicateBrowser(browserType: browserType)
        
        switch browserType {
        case .SFSafariViewController:
            self.openSFSafariViewController()
        case .WebView:
            self.openWebView()
        case .ExternalBrowser:
            self.openExternalBrowser()
        }
    }
    
    private func setIndicateBrowser(browserType: BrowserType) {
        var text = ""
        if browserType != .WebView {
            text = "Opening \(browserType)..."
        }
        
        indicateType.text = text
    }
    
    private func generateURL() -> URL? {
        guard let urlString = urlString else {
            debugPrint("-->> urlString is null")
            return nil
        }
        
        return URL(string: urlString)
    }
}

// MARK: - WebView
extension WebViewViewController {
    internal func openWebView() {
        self.configureWebview()
        self.loadWebview()
    }
    
    private func configureWebview() {
        self.webview.frame = self.view.frame
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self
        self.view.addSubview(self.webview)
    }
    
    private func loadWebview() {
        guard let url = self.generateURL() else {
            debugPrint("-->> URL generate error")
            return
        }
        
        let request = URLRequest(url: url)
        
        self.webview.load(request)
        self.webview.allowsBackForwardNavigationGestures = true
    }
}

// MARK: WKWebView WKUIDelegate
/// The methods for presenting native user interface elements on behalf of a webpage.
extension WebViewViewController: WKUIDelegate {
    
}

// MARK: WKWebView WKNavigationDelegate
/// Methods for accepting or rejecting navigation changes, and for tracking the progress of navigation requests.
extension WebViewViewController: WKNavigationDelegate {
    
}

// MARK: - SFSafariViewController
extension WebViewViewController: SFSafariViewControllerDelegate {
    internal func openSFSafariViewController() {
        guard let url = self.generateURL() else {
            debugPrint("-->> URL generate error")
            return
        }
        
        self.safariViewController = SFSafariViewController(url: url)
        self.present(self.safariViewController, animated: true)
        self.safariViewController.delegate = self
        self.dismiss(animated: false)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.safariViewController.dismiss(animated: true)
    }
}

// MARK: - External Browser
extension WebViewViewController {
    internal func openExternalBrowser() {
        guard let url = self.generateURL() else {
            debugPrint("-->> URL generate error")
            return
        }
        
        let application = UIApplication.shared
        
        guard application.canOpenURL(url) else {
            debugPrint("-->> Can not open the browser")
            return
        }
        
        application.open(url)
    }
}
