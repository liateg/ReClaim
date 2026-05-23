import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:frontend/utils/theme/app_theme.dart';
import 'package:frontend/features/items/presentation/widgets/category_chip.dart';
import './claim_empty.dart';
import '../widgets/claim_card.dart';
import 'claim_withdraw.dart';
import 'claim_delete.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/claims/Riverpod/claim_provider.dart';

class ClaimsScreen extends ConsumerStatefulWidget {
  const ClaimsScreen({super.key});

  @override
  ConsumerState<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends ConsumerState<ClaimsScreen> {
  String _selectedStatus = 'All';

  Future<void> _onRefresh() async {
    await ref.read(claimProvider.notifier).loadClaims();
  }

  @override
  Widget build(BuildContext context) {
    final claimState = ref.watch(claimProvider);
    final allClaims = claimState.claims;

    final filteredClaims = _selectedStatus == 'All'
        ? allClaims
        : allClaims.where((c) {
            return c.status.name.toLowerCase() == _selectedStatus.toLowerCase();
          }).toList();

    ref.listen<String?>(claimProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), backgroundColor: Colors.red.shade800),
        );
        ref.read(claimProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.detailScreenBackground,
      appBar: const CustomAppBar(title: 'My Claims', back: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Track the status of your lost and found claims here.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),

          // FILTER BAR
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _statusChip('All'),
                _statusChip('Pending'),
                _statusChip('Approved'),
                _statusChip('Rejected'),
                _statusChip('Withdrawn'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: filteredClaims.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'No $_selectedStatus claims found.',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pull down to refresh',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filteredClaims.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final claimObj = filteredClaims[index];
                        final isPending = claimObj.status.name.toLowerCase() == 'pending';
                        
                        return ClaimCard(
                          claim: claimObj,
                          onWithdraw: () async {
                            if (isPending) {
                              final confirmed = await showClaimWithdrawDialog(context);
                              if (confirmed) {
                                await ref.read(claimProvider.notifier).withdrawClaim(claimObj.id);
                              }
                            } else {
                              final confirmed = await showClaimDeleteDialog(context);
                              if (confirmed) {
                                await ref.read(claimProvider.notifier).removeClaim(claimObj.id);
                              }
                            }
                          },
                          onTap: () => context.go('/claims/${claimObj.id}'),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CategoryChip(
        label: label,
        isSelected: _selectedStatus == label,
        onTap: () => setState(() => _selectedStatus = label),
      ),
    );
  }
}
