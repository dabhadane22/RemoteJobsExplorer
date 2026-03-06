import SwiftUI
import WebKit

public struct HTMLView: UIViewRepresentable {
    public let htmlContent: String

    public func makeUIView(context: Context) -> WKWebView {
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = false

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = pagePrefs

        let webView = WKWebView(frame: .zero, configuration: config)

        // Let SwiftUI control the background and scrolling behavior where possible
        webView.isOpaque = false

        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        // Inject some CSS to adjust formatting, padding, and font size based on device mode
        let headerString = """
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                :root {
                    color-scheme: light dark;
                }
                body {
                    font-family: -apple-system, system-ui;
                    font-size: 16px;
                    padding: 0;
                    margin: 0;
                }
                a {
                    color: #007aff;
                }
            </style>
            """

        let formattedHTML = "\(headerString)\(htmlContent)"
        uiView.loadHTMLString(formattedHTML, baseURL: nil)
    }
}
