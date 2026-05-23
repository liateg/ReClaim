import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:frontend/utils/theme/app_theme.dart';
import './claim_empty.dart';
import '../widgets/claim_card.dart';
import '../../data/mock/mock_claims.dart';
import 'claim_withdraw.dart';
import 'claim_delete.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/claims/Riverpod/claim_provider.dart';

class ClaimsScreen extends ConsumerWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimState = ref.watch(claimProvider);
    final claims = claimState.claims;

    if (claims.isEmpty) {
      return const ClaimEmptyScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.detailScreenBackground,
      appBar: CustomAppBar(title: 'My Claims', back: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              'Track the status of your lost and found claims here.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: claims.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final claimObj = claims[index];
                final isPending = claimObj.status.name.toLowerCase() == 'pending';

                return ClaimCard(
                  claim: claimObj,
                  onWithdraw: () async {
                    if (isPending) {
                      await showClaimWithdrawDialog(context);
                    } else {
                      await showClaimDeleteDialog(context);
                    }
                  },
                  onTap: () => context.go('/claims/${claimObj.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}