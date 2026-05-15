import SwiftUI
import WebKit

class CloudflareManager: NSObject, ObservableObject, WKNavigationDelegate {
    static let shared = CloudflareManager()
    
    @Published var isBypassed: Bool = false
    var userAgent: String = ""
    var cookies: [HTTPCookie] = []
    
    private var webView: WKWebView!
    private let targetURL = URL(string: "https://anime3rb.com")!
    
    override init() {
        super.init()
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
    }
    
    func startBypass() {
        let request = URLRequest(url: targetURL)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { [weak self] (result, error) in
            guard let self = self, let title = result as? String else { return }
            if title.contains("Just a moment") || title.contains("Cloudflare") {
                // Still challenged, wait and WKWebView will auto-reload
                return
            }
            
            self.webView.evaluateJavaScript("navigator.userAgent") { (ua, _) in
                if let userAgent = ua as? String {
                    self.userAgent = userAgent
                }
                
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    self.cookies = cookies
                    DispatchQueue.main.async {
                        self.isBypassed = true
                    }
                }
            }
        }
    }
}

// Invisible view to attach to the root hierarchy
struct CloudflareBypassView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        return CloudflareManager.shared.webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
