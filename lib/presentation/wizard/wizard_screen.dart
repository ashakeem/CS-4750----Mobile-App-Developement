import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/gift_brief.dart';
import '../../data/providers.dart';

class WizardScreen extends ConsumerStatefulWidget {
  const WizardScreen({super.key});

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Wizard data
  String? selectedOccasion;
  String? selectedRelationship;
  String? selectedAgeRange;
  List<String> selectedInterests = [];
  String? selectedBudget;

  final List<String> occasions = [
    'Birthday',
    'Anniversary',
    'Christmas',
    'Graduation',
    'Other (please specify)',
  ];

  final List<String> relationships = [
    'Romantic Partner',
    'Friend',
    'Family Member',
    'Colleague',
    'Other (please specify)',
  ];

  final List<String> ageRanges = [
    'Under 18',
    '18-30',
    '31-50',
    'Over 50',
    'Other (please specify)',
  ];

  final List<String> interests = [
    'Tech',
    'Books',
    'Sports',
    'Food',
    'Art',
    'Other (please specify)',
  ];

  final List<String> budgets = [
    'Under \$25',
    '\$25-100',
    '\$100-250',
    'Over \$250',
    'Other (please specify)',
  ];

  // Add controllers for custom input
  final TextEditingController _occasionOtherController = TextEditingController();
  final TextEditingController _relationshipOtherController = TextEditingController();
  final TextEditingController _ageOtherController = TextEditingController();
  final TextEditingController _interestOtherController = TextEditingController();
  final TextEditingController _budgetOtherController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _occasionOtherController.dispose();
    _relationshipOtherController.dispose();
    _ageOtherController.dispose();
    _interestOtherController.dispose();
    _budgetOtherController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishWizard() {
    String occasion = selectedOccasion == 'Other (please specify)'
        ? _occasionOtherController.text.trim()
        : selectedOccasion!;
    String relationship = selectedRelationship == 'Other (please specify)'
        ? _relationshipOtherController.text.trim()
        : selectedRelationship!;
    String age = selectedAgeRange == 'Other (please specify)'
        ? _ageOtherController.text.trim()
        : selectedAgeRange!;
    List<String> interests = selectedInterests.contains('Other (please specify)')
        ? [
            ...selectedInterests.where((i) => i != 'Other (please specify)'),
            if (_interestOtherController.text.trim().isNotEmpty)
              _interestOtherController.text.trim(),
          ]
        : selectedInterests;
    String budget = selectedBudget == 'Other (please specify)'
        ? _budgetOtherController.text.trim()
        : selectedBudget!;

    if (occasion.isNotEmpty &&
        relationship.isNotEmpty &&
        age.isNotEmpty &&
        interests.isNotEmpty &&
        budget.isNotEmpty) {
      final brief = GiftBrief(
        occasion: occasion,
        relationship: relationship,
        ageRange: age,
        interests: interests,
        budget: budget,
      );
      ref.read(giftBriefProvider.notifier).updateBrief(brief);
      ref.read(giftSuggestionsProvider.notifier).fetchGiftSuggestions(brief);
    }
  }

  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return selectedOccasion != null;
      case 1:
        return selectedRelationship != null;
      case 2:
        return selectedAgeRange != null;
      case 3:
        return selectedInterests.isNotEmpty;
      case 4:
        return selectedBudget != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 5,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Step ${_currentStep + 1} of 5',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Wizard Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildOccasionStep(),
                  _buildRelationshipStep(),
                  _buildAgeRangeStep(),
                  _buildInterestsStep(),
                  _buildBudgetStep(),
                ],
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canProceed
                          ? (_currentStep == 4 ? _finishWizard : _nextStep)
                          : null,
                      child: Text(_currentStep == 4 ? 'Find Gifts' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccasionStep() {
    return _buildStep(
      title: 'What\'s the occasion?',
      options: occasions,
      selected: selectedOccasion,
      onSelect: (value) => setState(() => selectedOccasion = value),
      child: selectedOccasion == 'Other (please specify)'
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _occasionOtherController,
                decoration: const InputDecoration(labelText: 'Please specify'),
                onChanged: (val) => setState(() {}),
              ),
            )
          : null,
    );
  }

  Widget _buildRelationshipStep() {
    return _buildStep(
      title: 'Who is the gift for?',
      options: relationships,
      selected: selectedRelationship,
      onSelect: (value) => setState(() => selectedRelationship = value),
      child: selectedRelationship == 'Other (please specify)'
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _relationshipOtherController,
                decoration: const InputDecoration(labelText: 'Please specify'),
                onChanged: (val) => setState(() {}),
              ),
            )
          : null,
    );
  }

  Widget _buildAgeRangeStep() {
    return _buildStep(
      title: 'Age range?',
      options: ageRanges,
      selected: selectedAgeRange,
      onSelect: (value) => setState(() => selectedAgeRange = value),
      child: selectedAgeRange == 'Other (please specify)'
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _ageOtherController,
                decoration: const InputDecoration(labelText: 'Please specify'),
                onChanged: (val) => setState(() {}),
              ),
            )
          : null,
    );
  }

  Widget _buildInterestsStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select interests',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildMultiSelectList(
                    options: interests,
                    selectedValues: selectedInterests,
                    onChanged: (list) => setState(() => selectedInterests = list),
                  ),
                ),
                if (selectedInterests.contains('Other (please specify)'))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextField(
                      controller: _interestOtherController,
                      decoration: const InputDecoration(labelText: 'Please specify'),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStep() {
    return _buildStep(
      title: 'Budget?',
      options: budgets,
      selected: selectedBudget,
      onSelect: (value) => setState(() => selectedBudget = value),
      child: selectedBudget == 'Other (please specify)'
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _budgetOtherController,
                decoration: const InputDecoration(labelText: 'Please specify'),
                onChanged: (val) => setState(() {}),
              ),
            )
          : null,
    );
  }

  Widget _buildStep({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
    required Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: child ?? _buildOptionsList(
              options: options,
              selectedValue: selected,
              onChanged: onSelect,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList({
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedValue == option;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(option),
            selected: isSelected,
            selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
            leading: Radio<String>(
              value: option,
              groupValue: selectedValue,
              onChanged: (value) => onChanged(value!),
            ),
            onTap: () => onChanged(option),
          ),
        );
      },
    );
  }

  Widget _buildMultiSelectList({
    required List<String> options,
    required List<String> selectedValues,
    required ValueChanged<List<String>> onChanged,
  }) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedValues.contains(option);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(option),
            selected: isSelected,
            selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
            leading: Checkbox(
              value: isSelected,
              onChanged: (value) {
                if (value == true) {
                  onChanged([...selectedValues, option]);
                } else {
                  onChanged(selectedValues.where((v) => v != option).toList());
                }
              },
            ),
            onTap: () {
              if (isSelected) {
                onChanged(selectedValues.where((v) => v != option).toList());
              } else {
                onChanged([...selectedValues, option]);
              }
            },
          ),
        );
      },
    );
  }
} 