part of '../study_planner_screen.dart';

// _StudyPlannerScreenState: _buildErrorScreen, _buildGeneratingDialog, _showSuccessAnimation, _showCompletionAnimation, _buildLoadingScreen, _buildProfileSelectionSection
extension StudyPlannerScreenStateSection01 on _StudyPlannerScreenState {
  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Unable to load study planner',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _retryCount < 3 ? _retryInitialization : null,
                icon: Icon(Icons.refresh),
                label: Text('Try Again (${_retryCount + 1}/3)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              if (_retryCount >= 3)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Text(
                        'Too many attempts',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // Reset retry count after some time
                          Future.delayed(Duration(minutes: 5), () {
                            setState(() {
                              _retryCount = 0;
                            });
                          });
                        },
                        child: Text('Try again in 5 minutes'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _profileOptions.firstWhere(
                        (opt) => opt['profile'] == _selectedProfile,
                        orElse: () => _profileOptions[1],
                      )['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _profileOptions
                            .firstWhere(
                              (opt) => opt['profile'] == _selectedProfile,
                              orElse: () => _profileOptions[1],
                            )['gradient'][0]
                            .withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1000.ms),

            SizedBox(height: 25),

            Text(
              'Creating Your Study Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              'Personalizing your ${_getProfileTitle()} schedule...',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 25),

            LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              color: _profileOptions.firstWhere(
                (opt) => opt['profile'] == _selectedProfile,
                orElse: () => _profileOptions[1],
              )['gradient'][0],
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessAnimation() {
    Get.snackbar(
      '🎉 Plan Created Successfully!',
      'Your study plan is ready!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      margin: EdgeInsets.all(20),
      borderRadius: 15,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  void _showCompletionAnimation(DailyActivity activity) {
    Get.showSnackbar(
      GetSnackBar(
        message: '🎉 ${activity.title} completed!',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.9),
        margin: EdgeInsets.all(20),
        borderRadius: 15,
        animationDuration: Duration(milliseconds: 500),
        forwardAnimationCurve: Curves.easeOutBack,
        icon: Icon(Icons.check_circle, color: Colors.white),
        shouldIconPulse: true,
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: Text('Dismiss', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(Icons.school, size: 40, color: Colors.white),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms),
            SizedBox(height: 20),
            Text(
              'Loading Study Planner...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                color: Color(0xFF667EEA),
                minHeight: 3,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelectionSection() {
    final selectedOption = _profileOptions.firstWhere(
      (opt) => opt['profile'] == _selectedProfile,
      orElse: () => _profileOptions[1],
    );

    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Learning Style',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select the pace that matches your learning preferences',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),

          // Profile Cards - Horizontal Scroll
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _profileOptions.map((option) {
                final profile = option['profile'] as LearningProfile;
                final isSelected = _selectedProfile == profile;
                final gradientColors = option['gradient'] as List<Color>;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProfile = profile;
                    });
                  },
                  child: Container(
                    width: 180,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected
                            ? gradientColors
                            : [Colors.white, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? gradientColors[0].withOpacity(0.3)
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isSelected ? 0.1 : 0.04,
                          ),
                          blurRadius: 3,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : gradientColors[0].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Icon(
                                option['icon'] as IconData,
                                color: isSelected
                                    ? Colors.white
                                    : gradientColors[0],
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            option['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            option['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                            ),
                          ),
                          Spacer(),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Selected',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          // Generate Plan Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: selectedOption['gradient'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: selectedOption['gradient'][0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _isGeneratingSchedule ? null : _generateSchedule,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGeneratingSchedule)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(Icons.auto_awesome, size: 22, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        _isGeneratingSchedule
                            ? 'Creating Your Plan...'
                            : 'Generate Study Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, end: 0);
  }
}
