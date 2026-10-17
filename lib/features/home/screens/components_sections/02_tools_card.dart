part of '../components.dart';

// BodyParts: _buildToolsCard, _buildGamesCard, _buildStatItem, _buildToolItem, _buildGameItem
extension _BodyPartsSection02 on BodyParts {
  Widget _buildToolsCard(BuildContext context) {
    return Hero(
      tag: 'toolsCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenToolsCard(toolItems: items),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3498DB).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                top: 20,
                child: Icon(
                  Icons.build_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Learning Toolkit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "Everything you need for academic success in one place",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Row(
                      children: [
                        _buildToolItem(Icons.person, "Profile"),
                        const SizedBox(width: 12),
                        _buildToolItem(Icons.security, "Privacy"),
                        const SizedBox(width: 12),
                        _buildToolItem(Icons.assessment, "Scores"),
                        const SizedBox(width: 12),
                        _buildToolItem(Icons.note_add, "Notes"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOut,
          delay: 300.ms,
        ),
      ),
    );
  }

  Widget _buildGamesCard(BuildContext context) {
    return Hero(
      tag: 'gamesCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenGamesCard(gameItems: gameItems),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9B59B6).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Play & Learn",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.videogame_asset_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text(
                      "Educational Games",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "Learn through play with our interactive game collection",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Row(
                      children: [
                        _buildGameItem("assets/bee.png", "Spelling Bee"),
                        const SizedBox(width: 12),
                        _buildGameItem("assets/ttt.png", "Tic Tac Toe"),
                        const SizedBox(width: 12),
                        _buildGameItem("assets/ttt.png", "Sudoku"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 900.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOut,
          delay: 400.ms,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGameItem(String image, String name) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Image.asset(
              image,
              width: 30,
              height: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
