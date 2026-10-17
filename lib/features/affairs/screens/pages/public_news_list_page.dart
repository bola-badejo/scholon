import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/public_news_detail_page.dart';

// Public News List Page
class PublicNewsListPage extends StatelessWidget {
  final String userType;

  const PublicNewsListPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffairsPublicController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'School News',
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
        if (controller.isLoadingNews.value && controller.newsPosts.isEmpty) {
          return _buildLoading();
        }
        
        if (controller.newsPosts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.article_rounded,
            title: 'No news posts',
            subtitle: 'Check back later for school news',
            color: Colors.blue,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.newsPosts.length,
          itemBuilder: (context, index) {
            final news = controller.newsPosts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PublicNewsListCard(news: news, userType: userType),
            );
          },
        );
      }),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
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

class _PublicNewsListCard extends StatelessWidget {
  final NewsPost news;
  final String userType;

  const _PublicNewsListCard({required this.news, required this.userType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PublicNewsDetailPage(news: news, userType: userType)),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.hasImages && news.imageUrls.isNotEmpty)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(news.imageUrls.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.content.length > 100 
                          ? '${news.content.substring(0, 100)}...' 
                          : news.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          news.timeAgo,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        Icon(Icons.visibility_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${news.views}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
