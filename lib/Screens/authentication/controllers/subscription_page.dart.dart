import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Models/user.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';

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

  Widget _buildUserInfoCard() {
    if (_currentUser == null) return Container();

    final isKidling = _isKidlingUser;
    final gradientColors = isKidling
        ? [Colors.pink.shade400, Colors.orange.shade400]
        : [const Color(0xFF6C63FF), const Color(0xFF4A44C6)];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _currentUser!.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isKidling ? 'Upgrading to Kidling Plans' : 'Upgrading to ${_userTypeDisplay} Plans',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (_currentUser is StudentUser) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Grade ${(_currentUser as StudentUser).gradeLevel} • ${(_currentUser as StudentUser).schoolName ?? "No school"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
                if (isKidling) ...[
                  const SizedBox(height: 4),
                  Text(
                    'For ${(_currentUser as ParentUser).childName ?? "your little learner"}',
                    style: TextStyle(fontSize: 12, color: Colors.pink.shade400),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _currentPlans[index];
    final isSelected = _selectedPlanIndex == index;
    final isPopular = plan['popular'] == true;
    final hasAnnualOption = plan.containsKey('annualPrice');
    final isKidling = _isKidlingUser;

    return GestureDetector(
      onTap: () => _handlePlanSelection(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(
          bottom: 16,
          left: isSelected ? 0 : 8,
          right: isSelected ? 0 : 8,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? plan['color']
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: plan['color'].withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isKidling ? Colors.pink.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isKidling ? Colors.pink.shade200 : Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: isKidling ? Colors.pink.shade700 : Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isKidling ? Colors.pink.shade700 : Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  plan['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: plan['color'],
                  ),
                ),
                if (isKidling && plan['name'] == 'Free')
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.child_care, color: plan['color'], size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₦${_isAnnual && hasAnnualOption ? plan['annualPrice'].toString() : plan['price'].toString()}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/${_isAnnual && hasAnnualOption ? 'year' : plan['duration'].toString().toLowerCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (hasAnnualOption && _isAnnual)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '₦${(_monthlyEquivalent).round()} per month',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ...plan['features'].map<Widget>((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            if (plan['limitations'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Limitations:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              ...plan['limitations'].map<Widget>((limitation) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            limitation,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 20),
            if (isSelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: plan['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: plan['color']),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: plan['color'], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'SELECTED',
                      style: TextStyle(
                        color: plan['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SELECT PLAN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    final hasAnnualOption = _currentPlans[_selectedPlanIndex].containsKey('annualPrice');
    
    if (!hasAnnualOption) return Container();

    final isKidling = _isKidlingUser;
    final accentColor = isKidling ? Colors.pink : Colors.deepPurple;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isAnnual ? 'Annual Billing' : 'Monthly Billing',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isAnnual
                    ? 'Save ${((_currentPlans[_selectedPlanIndex]['price'] * 12 - _currentPlans[_selectedPlanIndex]['annualPrice']) / (_currentPlans[_selectedPlanIndex]['price'] * 12) * 100).round()}% with annual plan'
                    : 'Pay monthly, cancel anytime',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch.adaptive(
            value: _isAnnual,
            activeColor: accentColor,
            onChanged: (value) {
              setState(() => _isAnnual = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _paymentMethods.map((method) {
              final isSelected = _selectedPaymentMethod == method;
              final isKidling = _isKidlingUser;
              final accentColor = isKidling ? Colors.pink : Colors.deepPurple;
              
              return ChoiceChip(
                label: Text(method),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPaymentMethod = selected ? method : null;
                  });
                },
                selectedColor: accentColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                avatar: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAgreement() {
    final isKidling = _isKidlingUser;
    final accentColor = isKidling ? Colors.pink : Colors.deepPurple;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() => _acceptTerms = value ?? false);
            },
            activeColor: accentColor,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '. I understand that my subscription will automatically renew unless cancelled at least 24 hours before the end of the current period.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final plan = _currentPlans[_selectedPlanIndex];
    final isKidling = _isKidlingUser;
    final accentColor = isKidling ? Colors.pink : Colors.deepPurple;
    final borderColor = isKidling ? Colors.pink.shade200 : Colors.deepPurple.shade200;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Plan:', style: TextStyle(color: Colors.grey[600])),
              Text(
                '${plan['name']} ${_userTypeDisplay}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Billing Cycle:', style: TextStyle(color: Colors.grey[600])),
              Text(
                _selectedPlanDuration,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount:', style: TextStyle(color: Colors.grey[600])),
              Text(
                '₦$_selectedPlanPrice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          if (_isAnnual)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Equivalent:', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    '₦${_monthlyEquivalent.round()}',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Processing...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isKidling ? 'Start Kidling Adventure' : 'Subscribe Now',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Secure payment powered by PayStack',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
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

class SubscriptionSuccessDialog extends StatelessWidget {
  final String planName;
  final double amount;
  final String duration;
  final bool isAnnual;
  final String paymentMethod;
  final bool isKidling;

  const SubscriptionSuccessDialog({
    Key? key,
    required this.planName,
    required this.amount,
    required this.duration,
    required this.isAnnual,
    required this.paymentMethod,
    this.isKidling = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = isKidling ? Colors.pink : Colors.deepPurple;
    final icon = isKidling ? Icons.child_care : Icons.check_circle;
    final title = isKidling ? 'Welcome to Kidling!' : 'Subscription Successful!';
    final message = isKidling
        ? 'Your child\'s learning adventure begins now!'
        : 'Welcome to $planName plan';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plan:', style: TextStyle(color: Colors.grey[600])),
                      Text(planName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount:', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        '₦$amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Duration:', style: TextStyle(color: Colors.grey[600])),
                      Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Method:', style: TextStyle(color: Colors.grey[600])),
                      Text(paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                children: [
                  const TextSpan(text: 'Your subscription is now active. '),
                  TextSpan(
                    text: 'A receipt has been sent to your email.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.until((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isKidling ? 'Start Playing & Learning' : 'Start Learning Now',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.toNamed('/subscription-details'),
              child: Text(
                'View Subscription Details',
                style: TextStyle(color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}