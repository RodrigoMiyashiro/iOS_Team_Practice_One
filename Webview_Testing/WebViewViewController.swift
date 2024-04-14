import UIKit
import SafariServices
import WebKit

final class WebViewViewController: UIViewController {
    var urlString: String?
    var browserType: BrowserType?
    
    private var webview: WKWebView!
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
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        
        let preferences = WKWebpagePreferences()
        preferences.preferredContentMode = .mobile
        webViewConfig.defaultWebpagePreferences = preferences
        webViewConfig.dataDetectorTypes = [.all]
        
        self.webview = WKWebView(frame: self.view.frame, configuration: webViewConfig)
//        self.webview.frame = self.view.frame
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self
        
        
        self.webview.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"
        
        self.webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
//        self.webview.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        self.webview.addObserver(self, forKeyPath: "URL", options: [.new, .old], context: nil)
        
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print("Webview progress. \(Float(self.webview.estimatedProgress))")
        }
        
        if keyPath == "url" {
            debugPrint("Webview URL [1]: \(self.webview.url?.absoluteString ?? "!@#$")")
        }
        
        if let newValue = change?[.newKey] as? Int, let oldValue = change?[.oldKey] as? Int, newValue != oldValue {
            debugPrint("NEW: \(change?[.newKey])")
        } else {
            debugPrint("OLD: \(change?[.oldKey])")
        }
        
        self.webview.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                debugPrint("COOKIE: \(cookie)")
            }
        }
    }
}

// MARK: WKWebView WKUIDelegate
/// The methods for presenting native user interface elements on behalf of a webpage.
extension WebViewViewController: WKUIDelegate {
    
}

// MARK: WKWebView WKDownloadDelegate
//extension WebViewViewController: WKDownloadDelegate {
//    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
//        
//        completionHandler(webview.url)
//    }
//    
//    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {
//        <#code#>
//    }
//    
//    
//}

// MARK: WKWebView WKNavigationDelegate
/// Methods for accepting or rejecting navigation changes, and for tracking the progress of navigation requests.
extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        debugPrint("-->> Did Fail Provisional: \(error._code) | \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        debugPrint("-->> Did Start!!!")
        
        if let url = webView.url?.absoluteString {
            debugPrint("-->> URL: \(url)")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("-->> Did Finish!!!")
        
//        if let url = webView.url?.absoluteString {
//            debugPrint("-->> URL: \(url )")
//        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        debugPrint("-->> [decidePolicyFor navigationAction 1]: \(webView.url?.absoluteString ?? "!@#%$")")
        debugPrint("-->> [decidePolicyFor navigationAction 2]: \(navigationAction.request.url?.absoluteString ?? "!@#%$")")
        
        if navigationAction.shouldPerformDownload {
            debugPrint("-->> Here 1 <<--")
            return .download
        }
        
        return .allow
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        debugPrint("-->> [decidePolicyFor navigationResponse 1]: \(webView.url?.absoluteString ?? "!@#%$")")
        debugPrint("-->> [decidePolicyFor navigationResponse 2]: \(navigationResponse.response.url?.absoluteString ?? "!@#%$")")
        
        if let mimeType = navigationResponse.response.mimeType {
            debugPrint("-->> MIME Type: \(mimeType)")
        }
        
        if navigationResponse.canShowMIMEType {
            debugPrint("-->> Here 2 <--")
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.download)
    }
    
    
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
