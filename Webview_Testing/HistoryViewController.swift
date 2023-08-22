import UIKit
import CoreData

final class HistoryViewController: UIViewController {
    private let dbController: CRUD = DBController()
    
    private var result: [NSManagedObject] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
    }
    
    private func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.retriveURL()
    }
    
    private func retriveURL() {
        guard let result = self.dbController.retrieve(entityName: .Content, predicate: nil) as? [NSManagedObject] else {
            return
        }
        
        self.result = result
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.result.count > 0 {
            return 65
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        let row = indexPath.row
        let item = self.result[row]
        
        guard
            let url = item.value(forKey: "url") as? String,
            let date = item.value(forKey: "date") as? Date else {
            return cell
        }
        
        cell.textLabel?.text = url
        cell.detailTextLabel?.text = date.brFormat()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let itemSelected = self.result[indexPath.row]
        guard let url = itemSelected.value(forKey: "url") as? String else {
            return
        }
        
        self.showActionSheet(urlString: url)
    }
}

extension HistoryViewController {
    internal func showActionSheet(urlString: String) {
        let alertController = UIAlertController(title: "Browser", message: "Choose which browser you want to open", preferredStyle: .actionSheet)
        
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel)
        let webViewAlert = UIAlertAction(title: "WebView", style: .default) { _ in
            self.navigateTo(browserType: .WebView, with: urlString)
            debugPrint("-->> Webview")
            
        }
        let safariViewControllerAlert = UIAlertAction(title: "SFSafariViewController", style: .default) { _ in
            self.navigateTo(browserType: .SFSafariViewController, with: urlString)
            debugPrint("-->> SafariViewController")
        }
        let externalBrowserAlert = UIAlertAction(title: "External Browser", style: .default) { _ in
            self.navigateTo(browserType: .ExternalBrowser, with: urlString)
            debugPrint("-->> External Browser")
        }
        
        alertController.addAction(cancelAlert)
        alertController.addAction(webViewAlert)
        alertController.addAction(safariViewControllerAlert)
        alertController.addAction(externalBrowserAlert)
        
        self.present(alertController, animated: true)
    }
    
    private func navigateTo(browserType: BrowserType, with urlString: String) {
        let dict: [String: Any] = ["urlString": urlString, "browserType": browserType]
        self.performSegue(withIdentifier: "webViewViewController", sender: dict)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "webViewViewController" else { return }
            
        if let webviewViewController = segue.destination as? WebViewViewController, let result = sender as? [String: Any] {
            webviewViewController.urlString = result["urlString"] as? String
            webviewViewController.browserType = result["browserType"] as? BrowserType
        }
    }
}
