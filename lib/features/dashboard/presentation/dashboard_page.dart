import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/config/providers.dart';
import '../../../core/config/route_names.dart';
import '../../auth/data/auth_state_notifier.dart';
import '../data/dashboard_providers.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/errors/api_exception.dart';
import '../data/models.dart';
import '../../../core/widgets/primary_button.dart';

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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfilePrompt(),
                    const SizedBox(height: 16),
                    _MonthlyTotalHeader(),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Recent Catatan', onRefresh: () => ref.read(dashboardRefreshProvider.notifier).bump()),
                    const _RecentCatatanList(),
                    const SizedBox(height: 80), // leave space for floating bar
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: authenticated && !auth.loading ? const _FloatingActionsBar() : null,
    );
  }
}

Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
  final picker = ImagePicker();
  try {
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 2000, imageQuality: 90);
    if (picked == null) return;
    final repo = ref.read(uploadRepoProvider);
    final upload = await repo.uploadImage(filePath: picked.path);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploaded #${upload.id}')),
    );
    ref.read(dashboardRefreshProvider.notifier).bump();
  } catch (e) {
    final msg = e is ApiException ? e.message : 'Upload failed';
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

class _ProfilePrompt extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return profileAsync.when(
      data: (p) => p == null
          ? Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile Incomplete', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Complete your profile to enable uploads & automatic OCR notes.'),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Create Profile',
                      onPressed: () => _showCreateProfileDialog(context, ref),
                    ),
                  ],
                ),
              ),
            )
          : Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text('Profile: ${p.name}')),
                TextButton(
                  onPressed: () => _showCreateProfileDialog(context, ref, existing: p),
                  child: const Text('Edit'),
                )
              ],
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
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.summarize, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total amount ($monthLabel)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  revenueAsync.when(
                    data: (list) {
                      final match = list.firstWhere(
                        (e) => e.month == monthLabel,
                        orElse: () => RevenueMonth(month: monthLabel, total: 0),
                      );
                      return Text('${match.total}', style: Theme.of(context).textTheme.headlineSmall);
                    },
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (_, __) => const Text('--'),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.revenue),
              child: const Text('Details'),
            )
          ],
        ),
      ),
    );
  }
}

// Removed legacy metric cards

class _SectionHeader extends StatelessWidget {
  final String title; final VoidCallback onRefresh;
  const _SectionHeader({required this.title, required this.onRefresh});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
      IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, size: 18))
    ],
  );
}

class _RecentCatatanList extends ConsumerWidget {
  const _RecentCatatanList();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(recentCatatanProvider);
    return data.when(
      data: (list) => list.isEmpty ? const Text('No catatan yet') : Column(
        children: list.map((c) => ListTile(
          dense: true,
          leading: const Icon(Icons.receipt_long),
          title: Text(c.fileName),
          subtitle: Text(c.amount.toString()),
          trailing: c.date != null ? Text(c.date!.toLocal().toIso8601String().substring(0,10)) : null,
        )).toList(),
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
    final cs = Theme.of(context).colorScheme;
  return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: cs.primary,
          elevation: 6,
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
          onTap: () => Navigator.pushReplacementNamed(context, RouteNames.dashboard),
          child: const Center(child: FaIcon(FontAwesomeIcons.gauge, color: Colors.white)),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickAndUpload(context, ref),
                    child: const Center(child: Icon(Icons.camera_alt, color: Colors.white)),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
          onTap: () => _showCreateProfileDialog(context, ref),
          child: const Center(child: Icon(Icons.person, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                Navigator.pop(ctx);
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
