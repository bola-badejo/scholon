part of '../affairs_page.dart';

// AffairsMainScreen: _buildFloatingActionButton, _showQuickCreateMenu
extension _AffairsMainScreenSection02 on AffairsMainScreen {
  Widget _buildFloatingActionButton(AffairsController controller) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickCreateMenu(controller),
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Create',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showQuickCreateMenu(AffairsController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Create New',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickCreateCard(
                    icon: Icons.article_rounded,
                    label: 'News Post',
                    color: Colors.blue,
                    onTap: () {
                      Get.back();
                      Get.to(() => CreateNewsPage());
                    },
                  ),
                  _QuickCreateCard(
                    icon: Icons.event_rounded,
                    label: 'Event',
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      Get.to(() => CreateEventPage());
                    },
                  ),
                  _QuickCreateCard(
                    icon: Icons.poll_rounded,
                    label: 'Poll',
                    color: Colors.orange,
                    onTap: () {
                      Get.back();
                      Get.to(() => CreatePollPage());
                    },
                  ),
                  _QuickCreateCard(
                    icon: Icons.announcement_rounded,
                    label: 'Announcement',
                    color: Colors.purple,
                    onTap: () {
                      Get.back();
                      Get.to(() => CreateAnnouncementPage());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('Close')),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
