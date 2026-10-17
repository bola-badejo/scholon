import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/affairs/controllers/affairs_controller.dart';
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/affairs/screens/pages/create_news_page.dart';
import 'package:isapp/features/affairs/screens/pages/news_detail_page.dart';

// News List Page
class NewsListPage extends StatelessWidget {
  NewsListPage({super.key});

  final AffairsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All News',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => _searchNews(),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingNews.value && controller.newsPosts.isEmpty) {
          return _buildLoading();
        }
        
        if (controller.newsPosts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.article_rounded,
            title: 'No news posts',
            subtitle: 'Create your first news post',
            onAction: () => Get.to(() => CreateNewsPage()),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.newsPosts.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.newsPosts.length) {
              if (controller.isLoadingNews.value) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox();
            }
            
            final news = controller.newsPosts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _NewsListCard(news: news),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CreateNewsPage()),
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
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
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create New'),
            ),
          ],
        ),
      ),
    );
  }

  void _searchNews() {
    showSearch(
      context: Get.context!,
      delegate: _NewsSearchDelegate(),
    );
  }
}

class _NewsSearchDelegate extends SearchDelegate<String> {
  final AffairsController controller = Get.find();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<NewsPost>>(
      future: controller.searchNews(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$query"',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final news = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _NewsListCard(news: news),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox();
  }
}

class _NewsListCard extends StatelessWidget {
  final NewsPost news;

  const _NewsListCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => NewsDetailPage(news: news)),
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
            if (news.hasImages)
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
