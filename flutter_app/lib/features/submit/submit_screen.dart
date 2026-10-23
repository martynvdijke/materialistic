import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/utils/url_utils.dart';
import '../../l10n/app_localizations.dart';

enum _SubmitType { link, text }

class SubmitScreen extends ConsumerStatefulWidget {
  const SubmitScreen({super.key});

  @override
  ConsumerState<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends ConsumerState<SubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _text = TextEditingController();
  _SubmitType _type = _SubmitType.link;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final success = await ref
        .read(authControllerProvider)
        .submit(
          title: _title.text.trim(),
          url: _type == _SubmitType.link ? normalizeUrl(_url.text) : null,
          text: _type == _SubmitType.text ? _text.text.trim() : null,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.storySubmitted : l10n.postingFailed),
      ),
    );
    if (success) {
      _title.clear();
      _url.clear();
      _text.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.submitStory)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(l10n.loginRequired, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/login'),
                  child: Text(l10n.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.submitStory)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<_SubmitType>(
              segments: [
                ButtonSegment(
                  value: _SubmitType.link,
                  label: Text(l10n.url),
                  icon: const Icon(Icons.link),
                ),
                ButtonSegment(
                  value: _SubmitType.text,
                  label: Text(l10n.text),
                  icon: const Icon(Icons.notes),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.title),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l10n.title : null,
            ),
            const SizedBox(height: 16),
            if (_type == _SubmitType.link)
              TextFormField(
                controller: _url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: l10n.url),
                validator: (value) => isHttpUrl(normalizeUrl(value ?? ''))
                    ? null
                    : l10n.invalidUrl,
              )
            else
              TextFormField(
                controller: _text,
                minLines: 6,
                maxLines: 14,
                decoration: InputDecoration(labelText: l10n.text),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.text : null,
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.post),
            ),
          ],
        ),
      ),
    );
  }
}
