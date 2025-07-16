// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class CaptchaScreen extends StatefulWidget {
//   @override
//   _CaptchaScreenState createState() => _CaptchaScreenState();
// }

// class _CaptchaScreenState extends State<CaptchaScreen> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String url) async {
//             // Detect if CAPTCHA is solved and redirected
//             if (url.contains("your-target-after-captcha.com") ||
//                 url.contains("some_token_indicator")) {
//               // Optionally get token or notify user
//               print("CAPTCHA solved or redirected to: $url");
//               Navigator.pop(context, url);
//             }
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://example.com/your-captcha-url'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Bot Verification")),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }
