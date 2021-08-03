//
//  ViewController.swift
//  Project4
//
//  Created by Harsh Verma on 03/08/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var web: WKWebView!
    var progress: UIProgressView!
    
    var safeWebs = ["apple.com", "github.com", "facebook.com"]
    
    override func loadView() {
        web = WKWebView()
        web.navigationDelegate = self
        view = web
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Choose", style: .plain, target: self, action: #selector(didChoose))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let ref = UIBarButtonItem(barButtonSystemItem: .refresh, target: web, action: #selector(web.reload))
        let back = UIBarButtonItem(title: "Back", style: .plain, target: web, action: #selector(web.goBack))
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: web, action: #selector(web.goForward))
        progress = UIProgressView(progressViewStyle: .bar)
        progress.sizeToFit()
        let proButton = UIBarButtonItem(customView: progress)
        
        toolbarItems = [back, proButton, forward, space, ref]
        navigationController?.isToolbarHidden = false
        
        web.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        let url = URL(string: "https://" + safeWebs[0])!
        web.load(URLRequest(url: url))
        web.allowsBackForwardNavigationGestures = true
    }

    @objc func didChoose() {
        let alert = UIAlertController(title: "Open Page..", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Apple.com", style: .default, handler: openPage(action:)))
//        alert.addAction(UIAlertAction(title: "Google.com", style: .default, handler: openPage(action:)))
        
        for sites in safeWebs {
            alert.addAction(UIAlertAction(title: sites, style: .default, handler: openPage(action:)))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alert, animated: true, completion: nil)
    }
    
    func openPage(action: UIAlertAction) {
        guard let titleAction = action.title else {
            return
        }
        guard let url = URL(string: "https://" + titleAction) else {
            return
        }
        web.load(URLRequest(url: url))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progress.progress = Float(web.estimatedProgress)
        }
    }
}
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = web.title
    }
    
    //for safe checking url
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for sites in safeWebs {
                if host.contains(sites) {
                    decisionHandler(.allow)
                    return
                }
            }
            let pop = UIAlertController(title: "Warning!", message: "This site is currently blocked by your ISP", preferredStyle: .alert)
            pop.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(pop, animated: true)
        }
        decisionHandler(.cancel)
    }
}
