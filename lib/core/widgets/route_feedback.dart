import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A safe destination for route-level failures (for example, a missing
/// `extra` on a deep link). It never throws and always gives the user a way
/// back into a known flow.
class RouteUnavailableScreen extends StatelessWidget {
  final String title;
  final String message;
  final String safeDestination;
  final String destinationLabel;

  const RouteUnavailableScreen({
    super.key,
    required this.title,
    required this.message,
    required this.safeDestination,
    this.destinationLabel = 'Kembali',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SATU RUMAH')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(safeDestination),
                child: Text(destinationLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a user-facing explanation after the router sends a deep link to the
/// active role's shell. Query parameters keep the redirect side-effect free.
class RouteNotice extends StatefulWidget {
  final Widget child;
  final String? message;

  const RouteNotice({super.key, required this.child, this.message});

  @override
  State<RouteNotice> createState() => _RouteNoticeState();
}

class _RouteNoticeState extends State<RouteNotice> {
  @override
  void initState() {
    super.initState();
    final message = widget.message;
    if (message != null && message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void showUnavailableAction(
  BuildContext context, [
  String action = 'Fitur ini',
]) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$action belum tersedia di prototipe lokal.')),
    );
}
