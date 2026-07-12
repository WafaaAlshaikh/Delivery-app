// lib/screens/business/store_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/colors.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text_field.dart';
import '../../data/models/category_model.dart';
import '../../data/palestine_areas.dart';
import '../../providers/store_provider.dart';
import '../../services/store_service.dart';
import '../../services/location_service.dart'; 
import 'location_picker_screen.dart';

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  LatLng? _selectedLocation;
  String? _selectedAddress;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _feeInsideCityController = TextEditingController(text: '10');
  final _feeOutsideCityController = TextEditingController(text: '20');
  final _feeOccupiedController = TextEditingController(text: '70');
  final _minOrderController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '30');

  String? _selectedCategoryId;
  String? _selectedCity;
  bool _supportsDelivery = true;
  bool _supportsPickup = true;
  bool _saving = false;

  final _storeService = StoreService();
  final LocationService _locationService = LocationService(); 
  List<CategoryModel> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _storeService.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _loadingCategories = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _openingHoursController.dispose();
    _logoUrlController.dispose();
    _feeInsideCityController.dispose();
    _feeOutsideCityController.dispose();
    _feeOccupiedController.dispose();
    _minOrderController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCategoryId == null ||
        _selectedCity == null ||
        !_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null || _selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store name, category and location are required'),
          ),
        );
      }
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick your store location on the map'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final info = cityInfo[_selectedCity]!;

    final success = await ref.read(storeProvider.notifier).createStore(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      imageUrl: _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim(),
      address: _addressController.text.trim(),
      locationLat: _selectedLocation!.latitude,
      locationLng: _selectedLocation!.longitude,
      city: _selectedCity!,
      region: info.$1,
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      final store = ref.read(storeProvider).store;
      final approved = store?.approvalStatus == 'Verified';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approved
                ? '🎉 تم اعتماد متجرك تلقائياً! بتقدري تبلشي تضيفي منتجات.'
                : 'تم إنشاء المتجر، وهو قيد المراجعة حالياً.',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
        _getAddressFromLatLng(result.latitude, result.longitude);
      });
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final address = await _locationService.getAddressFromLatLng(lat, lng);
      
      setState(() {
        _selectedAddress = address;
        _addressController.text = address;
      });
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.storefront_outlined,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Create your store',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Set up your storefront to start receiving orders.',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Store name *',
            hint: 'e.g. Fresh Bites',
            prefixIcon: const Icon(Icons.storefront_outlined),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Store name is required'
                : null,
          ),
          const SizedBox(height: 16),

          _fieldLabel('Category *'),
          const SizedBox(height: 6),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),

          _fieldLabel('Description'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: _inputDecoration(hint: 'What does your store offer?'),
          ),
          const SizedBox(height: 16),

          _buildLocationPicker(),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _phoneController,
                  label: 'Phone *',
                  hint: '+970…',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _openingHoursController,
                  label: 'Opening hours',
                  hint: '9 AM – 10 PM',
                  prefixIcon: const Icon(Icons.access_time),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _logoUrlController,
            label: 'Logo image URL',
            hint: 'https://…',
            prefixIcon: const Icon(Icons.image_outlined),
          ),
          const SizedBox(height: 16),

          _fieldLabel('Store location (city) *'),
          const SizedBox(height: 6),
          _buildCityDropdown(),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _numberField(
                  controller: _feeInsideCityController,
                  label: 'Inside city (\$)',
                  hint: '10',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numberField(
                  controller: _feeOutsideCityController,
                  label: 'Outside city (\$)',
                  hint: '20',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numberField(
                  controller: _feeOccupiedController,
                  label: 'Occupied territories (\$)',
                  hint: '70',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _numberField(
                  controller: _minOrderController,
                  label: 'Min order (\$)',
                  hint: '0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  controller: _prepTimeController,
                  label: 'Prep time (min)',
                  hint: '30',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _switchTile(
                label: 'Delivery',
                value: _supportsDelivery,
                onChanged: (v) => setState(() => _supportsDelivery = v),
              ),
              const SizedBox(width: 24),
              _switchTile(
                label: 'Pickup',
                value: _supportsPickup,
                onChanged: (v) => setState(() => _supportsPickup = v),
              ),
            ],
          ),
          const SizedBox(height: 24),

          CustomButton(
            text: _saving ? 'Creating…' : 'Create store',
            isLoading: _saving,
            onPressed: _saving ? null : _submit,
          ),
          const SizedBox(height: 12),
          Text(
            'Your store will be reviewed by an admin before going live.',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Store Address *'),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Select location on map',
                prefixIcon: const Icon(Icons.location_on_outlined),
                readOnly: true,
                validator: (v) => (v == null || v.trim().isEmpty) 
                    ? 'Please select location on map' 
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _pickLocationOnMap,
              icon: const Icon(Icons.map, size: 18),
              label: const Text('Pick'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(70, 48),
              ),
            ),
          ],
        ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '📍 ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 11, 
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    if (_loadingCategories) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.centerLeft,
        child: const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      isExpanded: true,
      decoration: _inputDecoration(hint: 'Select a category'),
      hint: Text(
        'Select a category',
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      items: _categories
          .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)))
          .toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      isExpanded: true,
      decoration: _inputDecoration(hint: 'Select your city'),
      hint: Text(
        'Select your city',
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      items: palestineAreas
          .map((city) => DropdownMenuItem(value: city, child: Text(city)))
          .toList(),
      onChanged: (value) => setState(() => _selectedCity = value),
    );
  }

  Widget _switchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}