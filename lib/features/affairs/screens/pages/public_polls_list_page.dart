import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/public_poll_detail_page.dart';

// Public Polls List Page
class PublicPollsListPage extends StatelessWidget {
  final String userType;

  const PublicPollsListPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffairsPublicController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'School Polls',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Obx(() {
        if (controller.polls.isEmpty) {
          return _buildEmptyState(
            icon: Icons.poll_rounded,
            title: 'No polls',
            subtitle: 'Check back later for school polls',
            color: Colors.orange,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.polls.length,
          itemBuilder: (context, index) {
            final poll = controller.polls[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PublicPollListCard(poll: poll, userType: userType),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicPollListCard extends StatelessWidget {
  final Poll poll;
  final String userType;

  const _PublicPollListCard({required this.poll, required this.userType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PublicPollDetailPage(poll: poll, userType: userType)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.poll_rounded, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    poll.question.isNotEmpty ? poll.question : 'Poll Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...poll.options.take(2).map((option) {
              final percentage = poll.getOptionPercentage(option);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.text.isNotEmpty ? option.text : 'Option',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.orange,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${poll.totalVotes} votes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  poll.isExpired ? 'Ended' : 'Ends ${poll.endDate.day}/${poll.endDate.month}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
