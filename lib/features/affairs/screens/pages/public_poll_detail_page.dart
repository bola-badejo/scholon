import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';

// Public Poll Detail Page
class PublicPollDetailPage extends StatefulWidget {
  final Poll poll;
  final String userType;

  const PublicPollDetailPage({super.key, required this.poll, required this.userType});

  @override
  State<PublicPollDetailPage> createState() => _PublicPollDetailPageState();
}

class _PublicPollDetailPageState extends State<PublicPollDetailPage> {
  final AffairsPublicController controller = Get.find();
  final List<int> selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    final currentUserId = controller.currentUser.value?.uid;
    final hasVoted = poll.voterIds.contains(currentUserId);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Poll Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poll Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.poll_rounded,
                    size: 40,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poll.question.isNotEmpty ? poll.question : 'Poll Question',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          poll.category.isNotEmpty ? poll.category : 'General',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Poll Status
            Row(
              children: [
                Icon(
                  poll.isExpired ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: poll.isExpired ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  poll.isExpired ? 'Poll ended' : 'Active',
                  style: TextStyle(
                    fontSize: 16,
                    color: poll.isExpired ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_rounded, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${poll.totalVotes} votes',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Poll Options
            const Text(
              'Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            
            ...poll.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final percentage = poll.getOptionPercentage(option);
              final isSelected = selectedOptions.contains(index);
              
              return GestureDetector(
                onTap: () {
                  if (poll.isExpired || hasVoted) return;
                  
                  if (poll.isMultiChoice) {
                    setState(() {
                      if (isSelected) {
                        selectedOptions.remove(index);
                      } else {
                        selectedOptions.add(index);
                      }
                    });
                  } else {
                    setState(() {
                      selectedOptions.clear();
                      selectedOptions.add(index);
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (poll.isMultiChoice)
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                if (poll.isExpired || hasVoted) return;
                                setState(() {
                                  if (value == true) {
                                    selectedOptions.add(index);
                                  } else {
                                    selectedOptions.remove(index);
                                  }
                                });
                              },
                              activeColor: Colors.orange,
                            )
                          else
                            Radio(
                              value: index,
                              groupValue: selectedOptions.isNotEmpty ? selectedOptions.first : -1,
                              onChanged: (value) {
                                if (poll.isExpired || hasVoted) return;
                                setState(() {
                                  selectedOptions.clear();
                                  selectedOptions.add(value as int);
                                });
                              },
                              activeColor: Colors.orange,
                            ),
                          Expanded(
                            child: Text(
                              option.text.isNotEmpty ? option.text : 'Option ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (poll.totalVotes > 0)
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.orange,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                    ],
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 24),
            
            // Vote Button
            if (!poll.isExpired && !hasVoted && selectedOptions.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _voteOnPoll(poll),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.userType == 'parent' ? 'Vote as Parent' : 'Submit Vote',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            
            if (hasVoted)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have already voted on this poll',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _voteOnPoll(Poll poll) async {
    try {
      await controller.voteOnPoll(poll.id, selectedOptions);
      setState(() {
        // Refresh UI
      });
      Get.snackbar(
        'Success',
        'Vote submitted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
