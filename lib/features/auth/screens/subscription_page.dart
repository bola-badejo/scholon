import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/auth/screens/subscription_success_dialog.dart';

export 'package:isapp/features/auth/screens/subscription_success_dialog.dart';

part 'subscription_page_sections/01_user_info_card.dart';
part 'subscription_page_sections/02_terms_agreement.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({Key? key}) : super(key: key);

  @override
  _SubscriptionPlansPageState createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  final AuthService _authService = Get.find<AuthService>();
  BaseUser? _currentUser;
  bool _isLoading = true;
  
  // State variables
  int _selectedPlanIndex = 1; // Default to Basic plan
  bool _isAnnual = false;
  bool _isProcessing = false;
  String? _selectedPaymentMethod;
  bool _acceptTerms = false;
  
  // Payment methods
  final List<String> _paymentMethods = [
    'Card',
    'Bank Transfer',
    'PayStack',
    'Flutterwave',
    'Wallet',
  ];

  // Plan features based on user type
  final Map<UserType, List<Map<String, dynamic>>> _planFeatures = {
    UserType.student: [
      {
        'name': 'Trial',
        'price': 0,
        'duration': '30 days',
        'color': Colors.blueGrey,
        'features': [
          'Access to 5 basic courses',
          'Limited quizzes (10 per day)',
          'Basic study materials',
          'Community access',
          'Email support',
          '2 device limit',
        ],
        'limitations': [
          'No premium courses',
          'No exam preparation',
          'No progress analytics',
          'No certificate',
        ],
      },
      {
        'name': 'Basic',
        'price': 500,
        'annualPrice': 5000,
        'duration': 'Monthly',
        'color': Colors.blue,
        'popular': true,
        'features': [
          'All basic courses',
          'Unlimited quizzes',
          'Study materials',
          'Community access',
          'Priority support',
          '3 device limit',
          'Basic progress tracking',
        ],
        'limitations': [
          'Limited premium courses',
          'No family sharing',
          'Basic analytics only',
        ],
      },
      {
        'name': 'Premium',
        'price': 1200,
        'annualPrice': 12000,
        'duration': 'Monthly',
        'color': Colors.purple,
        'features': [
          'All courses including premium',
          'Unlimited quizzes & exams',
          'Advanced study materials',
          'Premium community access',
          '24/7 priority support',
          '5 device limit',
          'Advanced progress analytics',
          'Certificate of completion',
          'Exam preparation tools',
        ],
        'limitations': [
          'No family sharing',
        ],
      },
      {
        'name': 'Family',
        'price': 3000,
        'annualPrice': 30000,
        'duration': 'Monthly',
        'color': Colors.deepOrange,
        'features': [
          'Everything in Premium',
          'Up to 3 students',
          'Family progress dashboard',
          'Parental controls',
          'Shared device limit (10)',
          'Family study groups',
          'Bulk discount on additional students',
          'Dedicated account manager',
          'Custom study plans',
        ],
        'limitations': [],
      },
    ],
    UserType.teacher: [
      {
        'name': 'Trial',
        'price': 0,
        'duration': '30 days',
        'color': Colors.blueGrey,
        'features': [
          'Create up to 5 resources',
          '50 student limit',
          'Basic analytics',
          'Community access',
          'Email support',
          '5GB storage',
        ],
        'limitations': [
          'No advanced analytics',
          'No resource sharing',
          'Limited storage',
          'No certificate generation',
        ],
      },
      {
        'name': 'Basic',
        'price': 1500,
        'annualPrice': 15000,
        'duration': 'Monthly',
        'color': Colors.teal,
        'popular': true,
        'features': [
          'Create unlimited resources',
          '100 student limit',
          'Basic analytics',
          'Resource sharing',
          'Community access',
          'Priority support',
          '10GB storage',
          'Assignment creation',
        ],
        'limitations': [
          'No advanced analytics',
          'No certificate generation',
          'Limited video storage',
        ],
      },
      {
        'name': 'Pro',
        'price': 3500,
        'annualPrice': 35000,
        'duration': 'Monthly',
        'color': Colors.indigo,
        'features': [
          'Everything in Basic',
          '500 student limit',
          'Advanced analytics',
          'Certificate generation',
          'Video hosting',
          'Custom branding',
          '50GB storage',
          'Collaboration tools',
          'Parent communication portal',
        ],
        'limitations': [
          'No school-wide features',
        ],
      },
      {
        'name': 'School',
        'price': 10000,
        'annualPrice': 100000,
        'duration': 'Monthly',
        'color': Colors.deepPurple,
        'features': [
          'Everything in Pro',
          '2000 student limit',
          'School-wide analytics',
          'Admin dashboard',
          'Bulk student management',
          '200GB storage',
          'API access',
          'Custom integration',
          'Dedicated support',
          'Onboarding assistance',
        ],
        'limitations': [],
      },
    ],
    UserType.schoolAdmin: [
      {
        'name': 'Trial',
        'price': 0,
        'duration': '30 days',
        'color': Colors.blueGrey,
        'features': [
          'Up to 100 students',
          'Up to 10 teachers',
          'Basic attendance',
          'Basic reporting',
          'Email support',
        ],
        'limitations': [
          'No parent portal',
          'No finance module',
          'Limited support',
          'No custom branding',
        ],
      },
      {
        'name': 'Basic',
        'price': 25000,
        'duration': 'Annual',
        'color': Colors.green,
        'popular': true,
        'features': [
          'Up to 1000 students',
          'Up to 50 teachers',
          'Attendance system',
          'Basic reporting',
          'Parent portal',
          '40 support hours',
          'Basic analytics',
        ],
        'limitations': [
          'No finance module',
          'No custom branding',
          'Limited storage',
        ],
      },
      {
        'name': 'Advanced',
        'price': 50000,
        'duration': 'Annual',
        'color': Colors.blue,
        'features': [
          'Up to 5000 students',
          'Up to 200 teachers',
          'Everything in Basic',
          'Finance module',
          'Advanced analytics',
          'Custom reports',
          '80 support hours',
          'Video conferencing',
          'Exam management',
        ],
        'limitations': [
          'No API access',
          'Limited custom branding',
        ],
      },
      {
        'name': 'Enterprise',
        'price': 100000,
        'duration': 'Annual',
        'color': Colors.purple,
        'features': [
          'Unlimited students',
          'Unlimited teachers',
          'Everything in Advanced',
          'API access',
          'Custom branding',
          'White-label solution',
          '160 support hours',
          'Dedicated server',
          'Custom integration',
          'Training sessions',
          'SLA guarantee',
        ],
        'limitations': [],
      },
    ],
    UserType.parent: [
      {
        'name': 'Free',
        'price': 0,
        'duration': 'Forever',
        'color': Colors.blueGrey,
        'features': [
          'Monitor 1 child',
          'Basic progress reports',
          'Fee notifications',
          'School announcements',
          'Email support',
        ],
        'limitations': [
          'No real-time tracking',
          'Limited communication',
          'No academic reports',
          'No fee payment',
        ],
      },
      {
        'name': 'Premium',
        'price': 500,
        'annualPrice': 5000,
        'duration': 'Monthly',
        'color': Colors.amber,
        'popular': true,
        'features': [
          'Monitor up to 5 children',
          'Real-time progress tracking',
          'Detailed academic reports',
          'Communication portal',
          'Fee payment system',
          'Priority support',
          'Attendance alerts',
          'Behavior tracking',
          'Parent community',
        ],
        'limitations': [
          'Maximum 5 children',
        ],
      },
    ],
  };

  // Kidling-specific plan features
  final List<Map<String, dynamic>> _kidlingPlans = [
    {
      'name': 'Free',
      'price': 0,
      'duration': 'Forever',
      'color': Colors.blueGrey,
      'features': [
        '1 child profile',
        '3 activities per day',
        'Basic learning games',
        'Limited story access',
        'Basic progress tracking',
        'Email support',
      ],
      'limitations': [
        'No premium activities',
        'No offline access',
        'No detailed reports',
        'No parental controls',
      ],
    },
    {
      'name': 'Premium',
      'price': 300,
      'annualPrice': 3000,
      'duration': 'Monthly',
      'color': Colors.pink,
      'popular': true,
      'features': [
        '1 child profile',
        'Unlimited activities',
        'All learning games',
        'Full story library',
        'Detailed progress reports',
        'Offline access',
        'Parental controls',
        'Priority support',
        'Weekly activity suggestions',
        'Printable worksheets',
      ],
      'limitations': [
        'Single child only',
      ],
    },
    {
      'name': 'Family',
      'price': 600,
      'annualPrice': 6000,
      'duration': 'Monthly',
      'color': Colors.purple,
      'features': [
        'Up to 3 children',
        'Everything in Premium',
        'Individual child profiles',
        'Family progress dashboard',
        'Shared activity library',
        'Sibling comparison reports',
        'Custom learning paths',
        'Multi-device sync',
        'Dedicated support',
        'Early access to new content',
      ],
      'limitations': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _currentPlans {
    if (_currentUser == null) return _planFeatures[UserType.student]!;
    
    // Check if this is a Kidling parent
    if (_currentUser is ParentUser && (_currentUser as ParentUser).isKidlingParent) {
      return _kidlingPlans;
    }
    
    return _planFeatures[_currentUser!.userType]!;
  }

  double get _selectedPlanPrice {
    final plan = _currentPlans[_selectedPlanIndex];
    if (_isAnnual && plan.containsKey('annualPrice')) {
      return plan['annualPrice'].toDouble();
    }
    return plan['price'].toDouble();
  }

  String get _selectedPlanDuration {
    final plan = _currentPlans[_selectedPlanIndex];
    if (_isAnnual && plan.containsKey('annualPrice')) {
      return 'Annual (Save ${(((plan['price'] * 12) - plan['annualPrice']) / (plan['price'] * 12) * 100).round()}%)';
    }
    return plan['duration'];
  }

  double get _monthlyEquivalent {
    final plan = _currentPlans[_selectedPlanIndex];
    if (_isAnnual && plan.containsKey('annualPrice')) {
      return (plan['annualPrice'] / 12).roundToDouble();
    }
    return plan['price'].toDouble();
  }

  String get _userTypeDisplay {
    if (_currentUser == null) return 'Student';
    
    // Check for Kidling parent
    if (_currentUser is ParentUser && (_currentUser as ParentUser).isKidlingParent) {
      return 'Kidling';
    }
    
    switch (_currentUser!.userType) {
      case UserType.student:
        return 'Student';
        case UserType.kidling:
        return 'Kidling';
      case UserType.teacher:
        return 'Teacher';
      case UserType.schoolAdmin:
        return 'School';
      case UserType.parent:
        return 'Parent';
    }
  }

  bool get _isKidlingUser {
    return _currentUser is ParentUser && (_currentUser as ParentUser).isKidlingParent;
  }

  void _handlePlanSelection(int index) {
    setState(() {
      _selectedPlanIndex = index;
      // Reset annual toggle for plans that don't support it
      if (!_currentPlans[index].containsKey('annualPrice')) {
        _isAnnual = false;
      }
    });
  }

  Future<void> _processSubscription() async {
    if (!_acceptTerms) {
      Get.snackbar(
        'Terms Required',
        'Please accept the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      Get.snackbar(
        'Payment Method Required',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create subscription based on user type
      final selectedPlan = _currentPlans[_selectedPlanIndex];
      String planName = selectedPlan['name'];

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SubscriptionSuccessDialog(
          planName: planName,
          amount: _selectedPlanPrice,
          duration: _selectedPlanDuration,
          isAnnual: _isAnnual,
          paymentMethod: _selectedPaymentMethod!,
          isKidling: _isKidlingUser,
        ),
      );

      // Navigate back to home
      Get.until((route) => route.isFirst);
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      final isKidling = _isKidlingUser;
      final gradientColors = isKidling
          ? [Colors.pink.shade400, Colors.orange.shade400]
          : [const Color(0xFF6C63FF), const Color(0xFF4A44C6)];
      final accentColor = isKidling ? Colors.pink : Colors.deepPurple;

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
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isKidling ? Icons.child_care : Icons.credit_card,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Loading plans...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(color: accentColor),
            ],
          ),
        ),
      );
    }

    final isKidling = _isKidlingUser;
    final accentColor = isKidling ? Colors.pink : Colors.deepPurple;
    final gradientColors = isKidling
        ? [Colors.pink.shade400, Colors.orange.shade400]
        : [const Color(0xFF6C63FF), const Color(0xFF4A44C6)];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isKidling ? 'Kidling Plans' : 'Upgrade Plan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Get.toNamed('/subscription-faq'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isKidling ? 'Choose Your Kidling Plan' : 'Choose Your ${_userTypeDisplay} Plan',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isKidling
                    ? 'Fun, educational plans for your little learner'
                    : 'Select the perfect plan for your learning needs',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: isKidling ? 520 : 560,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: _currentPlans.length,
                onPageChanged: _handlePlanSelection,
                itemBuilder: (context, index) => _buildPlanCard(index),
              ),
            ),
            const SizedBox(height: 20),
            _buildBillingToggle(),
            _buildPaymentMethodSelector(),
            _buildTermsAgreement(),
            _buildSummaryCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
