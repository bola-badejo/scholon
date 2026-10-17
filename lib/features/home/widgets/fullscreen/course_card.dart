import 'package:flutter/material.dart';

import 'package:isapp/features/games/screens/spelling_bee/home.dart';
import 'package:isapp/features/games/screens/tic_tac_toe.dart';
import 'package:isapp/features/home/screens/components.dart';

export 'package:isapp/features/home/widgets/full_screen_course_card.dart';
export 'package:isapp/features/home/widgets/full_screen_exams_card.dart';
export 'package:isapp/features/home/widgets/full_screen_quiz_card.dart';
export 'package:isapp/features/home/widgets/full_screen_tools_card_2.dart';

class FullScreenGamesCard extends StatelessWidget {
  final List<GameDetail> gameItems;
  const FullScreenGamesCard({super.key, required this.gameItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Hero(
        tag: 'gamesCard',
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Background Image with Blur
              Image.asset(
                'assets/game_bg.jpeg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              
              // Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.purple.withOpacity(0.8),
                      Colors.purple[800]!.withOpacity(0.9),
                      Colors.purple[900]!.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
              
              // Content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Educational Games',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Learn through play with interactive games',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Feature Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Learning Through Play',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Develop skills while having fun with educational games',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Section Header
                      const Text(
                        'Available Games',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Games List
                      Column(
                        children: gameItems.asMap().entries.map((entry) {
                          // final index = entry.key;
                          final game = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  _handleGameTap(context, game.name);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Game Icon
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: game.color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: game.color.withOpacity(0.3)),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            game.image,
                                            width: 30,
                                            height: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // Game Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              game.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              game.description,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'by ${game.instructor} • ${game.time} min',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.5),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Play Button
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              game.color.withOpacity(0.8),
                                              game.color.withOpacity(0.6),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Play',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGameTap(BuildContext context, String gameName) {
    if (gameName == 'Bee Hive') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SpellingHome()),
      );
    } else if (gameName == 'Tic Tac Toe') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    } else if (gameName == 'Sudoku') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    }
  }
}
