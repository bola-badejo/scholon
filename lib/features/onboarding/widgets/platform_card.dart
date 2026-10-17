import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:isapp/features/onboarding/models/platform_option.dart';

class PlatformCard extends StatelessWidget {
  final PlatformOption platform;
  final bool isActive;
  final bool isDark;

  const PlatformCard({
    super.key,
    required this.platform,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: platform.id,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: platform.color.withOpacity(isActive ? 0.4 : 0.2),
                blurRadius: isActive ? 30 : 20,
                spreadRadius: isActive ? 3 : 1,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    platform.image,
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.multiply,
                    color: isDark ? Colors.black54 : Colors.black12,
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          platform.color.withOpacity(0.95),
                          platform.color.withOpacity(0.7),
                          platform.color.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 0.9],
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // PlatformOption Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 70 : 60,
                        height: isActive ? 70 : 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          platform.icon,
                          color: Colors.white,
                          size: isActive ? 32 : 28,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PlatformOption Name
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isActive ? 32 : 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        child: Text(platform.name),
                      ),

                      const SizedBox(height: 8),

                      // Tagline
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isActive ? 18 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        child: Text(platform.tagline),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isActive ? 1 : 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(
                            platform.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Select Indicator
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isActive ? 1 : 0,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Border
                if (isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
