part of '../subscription_page.dart';

// _SubscriptionPlansPageState: _buildUserInfoCard, _buildPlanCard, _buildBillingToggle, _buildPaymentMethodSelector
extension SubscriptionPlansPageStateSection01 on _SubscriptionPlansPageState {
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
}
