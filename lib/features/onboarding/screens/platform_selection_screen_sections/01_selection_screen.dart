part of '../platform_selection_screen.dart';

// _PlatformSelectionScreenState: _buildSelectionScreen, _buildDetailsScreen
extension PlatformSelectionScreenStateSection01 on _PlatformSelectionScreenState {
  Widget _buildSelectionScreen(Size size, bool isDark) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: size.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage == 0 ? 1 : 0.5,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Choose Your ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: 'PlatformOption',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: _platforms[_currentPage].color,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage == 0 ? 1 : 0.7,
                    child: Text(
                      'Swipe horizontally to explore platforms',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : const Color(0xFF6C757D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PlatformOption Cards Carousel
            SizedBox(
              height: size.height * 0.6,
              child: PageView.builder(
                controller: _controller,
                itemCount: _platforms.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final platform = _platforms[index];
                  final offset = index - _pageOffset;
                  final scale = 1 - (offset.abs() * 0.1);
                  final opacity = 1 - (offset.abs() * 0.3);

                  return Transform(
                    transform: Matrix4.identity()
                      ..scale(scale.clamp(0.9, 1.0)),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: opacity.clamp(0.7, 1.0),
                      child: GestureDetector(
                        onTap: () => _verticalController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: offset.abs() * 20,
                            horizontal: 8,
                          ),
                          child: PlatformCard(
                            platform: platform,
                            isActive: index == _currentPage,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page Indicator and PlatformOption Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Page Indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _platforms.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _platforms[_currentPage].color,
                      dotColor: isDark ? Colors.white24 : Colors.grey[300]!,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 6,
                      expansionFactor: 3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // PlatformOption Features
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_currentPage),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: _platforms[_currentPage].color.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Key Features',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _platforms[_currentPage].tagline,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white60 : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _platforms[_currentPage].color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _platforms[_currentPage].name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _platforms[_currentPage].color,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Features Grid
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.start,
                            children: _platforms[_currentPage].features.map((feature) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _platforms[_currentPage].color.withOpacity(isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _platforms[_currentPage].color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _platforms[_currentPage].color.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getFeatureIcon(feature),
                                        size: 16,
                                        color: _platforms[_currentPage].color,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        feature,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scroll Hint
                  Column(
                    children: [
                      Icon(
                        Icons.swipe_up,
                        color: _platforms[_currentPage].color,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Swipe up for details',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsScreen(Size size, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: size.height,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  _verticalController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _platforms[_currentPage].color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: _platforms[_currentPage].color,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // PlatformOption Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _platforms[_currentPage].color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _platforms[_currentPage].icon,
                      size: 32,
                      color: _platforms[_currentPage].color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _platforms[_currentPage].name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _platforms[_currentPage].color,
                          ),
                        ),
                        Text(
                          _platforms[_currentPage].tagline,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Hero Image
              Hero(
                tag: _platforms[_currentPage].id,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(_platforms[_currentPage].image),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        _platforms[_currentPage].color.withOpacity(0.3),
                        BlendMode.multiply,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Description Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: _platforms[_currentPage].color.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About ${_platforms[_currentPage].name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _platforms[_currentPage].description,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Features Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: _platforms[_currentPage].color.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._platforms[_currentPage].features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _platforms[_currentPage].color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                _getFeatureIcon(feature),
                                color: _platforms[_currentPage].color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getFeatureDescription(feature),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white60 : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _selectPlatform(_platforms[_currentPage]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _platforms[_currentPage].color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _platforms[_currentPage].icon,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with ${_platforms[_currentPage].name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Back Hint
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.swipe_down,
                      color: _platforms[_currentPage].color,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Swipe down to go back',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
