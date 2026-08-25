import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/repositories/admin_repository.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUserRepositoryProvider);
    final filtered = users
        .where((u) => u.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search users by name',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: Spacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: RakshakCard(
                  padding: EdgeInsets.zero,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Mobile')),
                      DataColumn(label: Text('State')),
                      DataColumn(label: Text('Joined')),
                      DataColumn(label: Text('Cases')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: filtered.map((u) {
                      return DataRow(
                        cells: [
                          DataCell(Text(u.name)),
                          DataCell(Text(u.mobileMasked)),
                          DataCell(Text(u.state)),
                          DataCell(Text(AppFormatters.date(u.joinedAt))),
                          DataCell(Text('${u.caseCount}')),
                          DataCell(Text(u.active ? 'Active' : 'Deactivated')),
                          DataCell(
                            TextButton(
                              onPressed: () => ref
                                  .read(adminUserRepositoryProvider.notifier)
                                  .setActive(u.id, !u.active),
                              child: Text(
                                u.active ? 'Deactivate' : 'Reactivate',
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
