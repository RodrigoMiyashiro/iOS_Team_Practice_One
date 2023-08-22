import UIKit
import CoreData

final class ViewController: UIViewController {
    private let dbController: CRUD = DBController()
    
    @IBOutlet weak var urlTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func openURL(_ sender: UIButton) {
        self.showActionSheet()
    }
    
    internal func showActionSheet() {
        self.urlTextField.resignFirstResponder()
        
        let alertController = UIAlertController(title: "Browser", message: "Choose which browser you want to open", preferredStyle: .actionSheet)
        
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel)
        let webViewAlert = UIAlertAction(title: "WebView", style: .default) { _ in
            self.navigateTo(browserType: .WebView)
            debugPrint("-->> Webview")
            
        }
        let safariViewControllerAlert = UIAlertAction(title: "SFSafariViewController", style: .default) { _ in
            self.navigateTo(browserType: .SFSafariViewController)
            debugPrint("-->> SafariViewController")
        }
        let externalBrowserAlert = UIAlertAction(title: "External Browser", style: .default) { _ in
            self.navigateTo(browserType: .ExternalBrowser)
            debugPrint("-->> External Browser")
        }
        
        alertController.addAction(cancelAlert)
        alertController.addAction(webViewAlert)
        alertController.addAction(safariViewControllerAlert)
        alertController.addAction(externalBrowserAlert)
        
        self.present(alertController, animated: true)
    }
    
    private func navigateTo(browserType: BrowserType) {
        self.insertURLToDB()
        
        self.performSegue(withIdentifier: "webViewViewController", sender: browserType)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "webViewViewController" else { return }
            
        if let webviewViewController = segue.destination as? WebViewViewController {
            webviewViewController.urlString = self.urlTextField.text
            webviewViewController.browserType = sender as? BrowserType
        }
    }
}
// MARK: - TextField Delegate
extension ViewController: UITextFieldDelegate {
    internal func dismissKeyboard() {
        self.urlTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismissKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.showActionSheet()
        
        return true
    }
}

// MARK: - DataBase
extension ViewController {
    func insertURLToDB() {
        guard
            let dbManager: NSManagedObject = self.dbController.create(entityName: .Content) as? NSManagedObject,
            let urlString = self.urlTextField.text else {
            return
        }
        
        self.dbController.insert(string: urlString, managedObject: dbManager)
    }
}
