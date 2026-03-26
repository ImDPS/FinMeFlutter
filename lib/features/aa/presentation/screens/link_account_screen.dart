import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';

class LinkAccountScreen extends StatefulWidget {
  final String consentUrl;
  final void Function(String accountId, String accountName, String institution) onConsentGranted;

  const LinkAccountScreen({
    super.key,
    required this.consentUrl,
    required this.onConsentGranted,
  });

  @override
  State<LinkAccountScreen> createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends State<LinkAccountScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (request) {
          if (request.url.startsWith('finme://consent-callback')) {
            // Parse accountId, accountName, institution from callback URL
            final uri = Uri.parse(request.url);
            final accountId   = uri.queryParameters['accountId']   ?? '';
            final accountName = uri.queryParameters['accountName'] ?? 'Linked Account';
            final institution = uri.queryParameters['institution'] ?? '';
            widget.onConsentGranted(accountId, accountName, institution);
            if (mounted) Navigator.of(context).pop();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.consentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Account', style: AppTextStyles.heading),
        backgroundColor: AppColors.background,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
