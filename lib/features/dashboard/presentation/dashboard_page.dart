import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/config/providers.dart';
import '../../../core/config/route_names.dart';
import '../../auth/data/auth_state_notifier.dart';
import '../data/dashboard_providers.dart';
import '../data/models.dart';
import '../../../core/ui/widgets/metric_card.dart';
import '../../../core/ui/widgets/receipt_list_tile.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/profile_banner.dart';
import '../../../core/ui/widgets/pill_bottom_nav.dart';
import '../../../core/ui/design_tokens.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final auth = ref.watch(authStateProvider);
  final authenticated = auth.status == AuthStatus.authenticated;
  // If not authenticated (and not still loading), redirect to login (post-frame to avoid build issues)
  if (!authenticated && !auth.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.popAndPushNamed(context, RouteNames.login);
        } else {
          Navigator.pushReplacementNamed(context, RouteNames.login);
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(auth.username != null ? 'Hi, ${auth.username}' : 'Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: authenticated && !auth.loading
          ? RefreshIndicator(
              onRefresh: () async => ref.read(dashboardRefreshProvider.notifier).bump(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfilePrompt(),
                    const SizedBox(height: Spacing.md),
                    _MonthlyTotalHeader(),
                    const SizedBox(height: Spacing.lg),
                    SectionHeader(
                      title: 'Recent Catatan',
                      onAction: () => ref.read(dashboardRefreshProvider.notifier).bump(),
                    ),
                    const _RecentCatatanList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: authenticated && !auth.loading ? const _FloatingActionsBar() : null,
    );
  }
}

// Upload via kamera

class _ProfilePrompt extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return profileAsync.when(
      data: (p) => ProfileBanner(
        profileName: p?.name,
        onCreateOrEdit: () => _showCreateProfileDialog(context, ref, existing: p),
      ),
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MonthlyTotalHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(revenueProvider);
    final now = DateTime.now();
    final monthLabel = '${now.year}-${now.month.toString().padLeft(2,'0')}';
    final currency = NumberFormat.decimalPattern();
    return revenueAsync.when(
      data: (list) {
        final match = list.firstWhere(
          (e) => e.month == monthLabel,
          orElse: () => RevenueMonth(month: monthLabel, total: 0),
        );
        return MetricCard(
          icon: Icons.summarize,
          title: 'Total amount ($monthLabel)',
          value: currency.format(match.total),
          onTap: () => Navigator.pushNamed(context, RouteNames.revenue),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (_, __) => const Text('--'),
    );
  }
}

// Removed legacy metric cards

// Local SectionHeader replaced by reusable component.

class _RecentCatatanList extends ConsumerWidget {
  const _RecentCatatanList();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(recentCatatanProvider);
    return data.when(
      data: (list) => list.isEmpty
          ? const Text('No catatan yet')
          : Column(
              children: list
                  .map((c) => ReceiptListTile(fileName: c.fileName, amount: c.amount, date: c.date))
                  .toList(),
            ),
      loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator()),
      error: (_, __) => const Text('Failed to load'),
    );
  }
}

// Recent uploads removed per request

class _FloatingActionsBar extends ConsumerWidget {
  const _FloatingActionsBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PillBottomNav(
      currentIndex: 0,
      icons: [FontAwesomeIcons.gauge, Icons.camera_alt, Icons.person],
      onTap: (i) {
        switch (i) {
          case 0:
            Navigator.pushReplacementNamed(context, RouteNames.dashboard);
            break;
          case 1:
            Navigator.pushNamed(context, RouteNames.camera);
            break;
          case 2:
            _showCreateProfileDialog(context, ref);
            break;
        }
      },
    );
  }
}

Future<void> _showCreateProfileDialog(BuildContext context, WidgetRef ref, {UserProfile? existing}) async {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final formKey = GlobalKey<FormState>();
  bool submitting = false;
  await showDialog(context: context, builder: (ctx) {
    return StatefulBuilder(builder: (ctx, setState) {
      return AlertDialog(
        title: Text(existing == null ? 'Create Profile' : 'Edit Profile'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v)=> v==null||v.isEmpty ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: submitting ? null : () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: submitting ? null : () async {
              if(!formKey.currentState!.validate()) return;
              setState(()=> submitting = true);
              try {
                await ref.read(profileRepoProvider).createProfile(name: nameCtrl.text.trim());
                ref.read(dashboardRefreshProvider.notifier).bump();
                // ignore editing extended fields for brevity
                  if (!context.mounted) return;
                  Navigator.pop(context);
              } finally { setState(()=> submitting = false); }
            },
            child: Text(submitting ? 'Saving...' : 'Save'),
          ),
        ],
      );
    });
  });
}

// Removed legacy add-note dialog
