// // lib/features/reports/presentation/screens/reports_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../features/reports/Riverpod/report_provider.dart';
// import '../../features/reports/data/models/report_model.dart';
// import '../../../../shared/widgets/appbar.dart';
// import '../../../../utils/theme/app_theme.dart';

// class ReportsScreen extends ConsumerWidget {
//   const ReportsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final reportsAsync = ref.watch(myReportsProvider);

//     return Scaffold(
//       backgroundColor: AppTheme.detailScreenBackground,
//       appBar: const CustomAppBar(title: 'My Reports', back: true),
//       body: reportsAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 48, color: Colors.red),
//               const SizedBox(height: 16),
//               Text('Error: $err'),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => ref.invalidate(myReportsProvider),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//         data: (reports) {
//           if (reports.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.report_off_outlined, size: 48, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'No reports yet',
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'You haven\'t submitted any reports',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: () async {
//               ref.invalidate(myReportsProvider);
//             },
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: reports.length,
//               itemBuilder: (context, index) {
//                 final report = reports[index];
//                 return _ReportCard(
//                   report: report,
//                   onDelete: () => _deleteReport(context, ref, report),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _ReportCard extends StatelessWidget {
//   final Report report;
//   final VoidCallback? onDelete;

//   const _ReportCard({required this.report, this.onDelete});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header: Reason and Status
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   report.reason.displayName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: report.status.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   report.status.displayName,
//                   style: TextStyle(
//                     color: report.status.color,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               if (onDelete != null)
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline,
//                       size: 20, color: Colors.red),
//                   onPressed: onDelete,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),

//           // Target (what was reported)
//           if (report.itemId != null || report.claimId != null)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Text(
//                 report.itemId != null
//                     ? 'Reported Item #${report.itemId}'
//                     : 'Reported Claim #${report.claimId}',
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),

//           // Description
//           if (report.description != null && report.description!.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Text(
//                 report.description!,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppTheme.grayText,
//                 ),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),

//           // Admin note (if any)
//           if (report.adminNote != null && report.adminNote!.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 8, bottom: 4),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Admin Note:',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       report.adminNote!,
//                       style: const TextStyle(fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           const SizedBox(height: 8),

//           // Date
//           Text(
//             'Reported: ${_formatDate(report.createdAt)}',
//             style: const TextStyle(fontSize: 12, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'Unknown date';
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
// lib/features/reports/presentation/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/reports/Riverpod/report_provider.dart';
import '../../features/reports/data/models/report_model.dart';
import '../../../../shared/widgets/appbar.dart';
import '../../../../utils/theme/app_theme.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  // ✅ Add delete function here
  Future<void> _deleteReport(Report report) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text(
            'Are you sure you want to delete "${report.reason.displayName}" report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // You need to add deleteReportProvider first
        await ref.read(deleteReportProvider(report.id.toString()).future);
        ref.invalidate(myReportsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Report deleted'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      backgroundColor: AppTheme.detailScreenBackground,
      appBar: const CustomAppBar(title: 'My Reports', back: true),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(myReportsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_off_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No reports yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('You haven\'t submitted any reports',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myReportsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportCard(
                  report: report,
                  onDelete: () =>
                      _deleteReport(report), // ✅ Pass delete function
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onDelete; // ✅ Add this

  const _ReportCard({required this.report, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.reason.displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: report.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.status.displayName,
                  style: TextStyle(
                      color: report.status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              // ✅ Delete button
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (report.itemId != null || report.claimId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                report.itemId != null
                    ? 'Reported Item #${report.itemId}'
                    : 'Reported Claim #${report.claimId}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          if (report.description != null && report.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                report.description!,
                style: const TextStyle(fontSize: 14, color: AppTheme.grayText),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (report.adminNote != null && report.adminNote!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Admin Note:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(report.adminNote!,
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Reported: ${_formatDate(report.createdAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.day}/${date.month}/${date.year}';
  }
}
