import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../models/vehicle.dart';
import '../viewmodels/garage_providers.dart';
import '../widgets/glass_container.dart';

class AddDataScreen extends ConsumerStatefulWidget {
  const AddDataScreen({super.key});

  @override
  ConsumerState<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends ConsumerState<AddDataScreen> {
  final _vehicleFormKey = GlobalKey<FormState>();
  final _timelineFormKey = GlobalKey<FormState>();
  final _distanceFormKey = GlobalKey<FormState>();
  final _maintenanceFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _batteryController = TextEditingController(text: '100');
  final _imageUrlController = TextEditingController();
  final _locationController = TextEditingController();

  final _timelineTitleController = TextEditingController();
  final _timelineMileageController = TextEditingController(text: '0');
  final _timelineDateController = TextEditingController();

  final _distanceDateController = TextEditingController();
  final _distanceController = TextEditingController(text: '0');

  final _maintenanceTitleController = TextEditingController();
  final _maintenanceDateController = TextEditingController();

  String? _selectedVehicleIdForTimeline;
  String? _selectedVehicleIdForDistance;
  String? _selectedVehicleIdForMaintenance;

  String _timelineType = 'maintenance';
  double _timelineProgress = 1.0;
  String _maintenanceStatus = 'Upcoming';

  // TODO: Remove unused _statusMessage field
// bool _statusMessage = false;
bool _isSaving = false;

  DateTime _timelineDate = DateTime.now();
  DateTime _distanceDate = DateTime.now();
  DateTime _maintenanceDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timelineDateController.text = DateFormat('yyyy-MM-dd').format(_timelineDate);
    _distanceDateController.text = DateFormat('yyyy-MM-dd').format(_distanceDate);
    _maintenanceDateController.text = DateFormat('yyyy-MM-dd').format(_maintenanceDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateNumberController.dispose();
    _batteryController.dispose();
    _imageUrlController.dispose();
    _locationController.dispose();

    _timelineTitleController.dispose();
    _timelineMileageController.dispose();
    _timelineDateController.dispose();

    _distanceDateController.dispose();
    _distanceController.dispose();

    _maintenanceTitleController.dispose();
    _maintenanceDateController.dispose();

    super.dispose();
  }

  void _showSnackBar(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.snackBarSuccess : AppColors.snackBarError,
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller, DateTime initialDate, ValueChanged<DateTime> onSelected) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.accent,
                onPrimary: AppColors.textPrimary,
                surface: AppColors.surface,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
    );
    if (selected != null) {
      onSelected(selected);
      controller.text = DateFormat('yyyy-MM-dd').format(selected);
    }
  }

  Future<void> _submitVehicle() async {
    if (!_vehicleFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(garageRepositoryProvider);
      final name = _nameController.text.trim();
      final plateNumber = _plateNumberController.text.trim();
      final battery = double.parse(_batteryController.text.trim());
      final location = _locationController.text.trim();
      final imageUrl = _imageUrlController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
          : _imageUrlController.text.trim();

      await repo.addVehicle(
        name: name,
        plateNumber: plateNumber,
        battery: battery,
        imageUrl: imageUrl,
        location: location,
      );

      ref.invalidate(vehiclesProvider);
      _vehicleFormKey.currentState!.reset();
      _batteryController.text = '100';

      _showSnackBar('Vehicle added to Firebase successfully.');
    } catch (error) {
      _showSnackBar('Failed to save vehicle: $error', success: false);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _submitTimeline() async {
    if (!_timelineFormKey.currentState!.validate()) return;
    if (_selectedVehicleIdForTimeline == null) {
      _showSnackBar('Select a vehicle for the timeline event.', success: false);
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(garageRepositoryProvider);
      final title = _timelineTitleController.text.trim();
      final mileage = int.parse(_timelineMileageController.text.trim());

      await repo.addTimelineEvent(
        vehicleId: _selectedVehicleIdForTimeline!,
        title: title,
        type: _timelineType,
        mileage: mileage,
        date: _timelineDate,
        progress: _timelineProgress,
      );

      _timelineFormKey.currentState!.reset();
      _timelineMileageController.text = '0';
      _timelineDate = DateTime.now();
      _timelineDateController.text = DateFormat('yyyy-MM-dd').format(_timelineDate);

      _showSnackBar('Timeline event added successfully.');
    } catch (error) {
      _showSnackBar('Failed to save timeline event: $error', success: false);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _submitDistance() async {
    if (!_distanceFormKey.currentState!.validate()) return;
    if (_selectedVehicleIdForDistance == null) {
      _showSnackBar('Select a vehicle for the distance log.', success: false);
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(garageRepositoryProvider);
      final distance = double.parse(_distanceController.text.trim());

      await repo.addDistanceLog(
        vehicleId: _selectedVehicleIdForDistance!,
        date: _distanceDate,
        distance: distance,
      );

      _distanceFormKey.currentState!.reset();
      _distanceController.text = '0';
      _distanceDate = DateTime.now();
      _distanceDateController.text = DateFormat('yyyy-MM-dd').format(_distanceDate);

      _showSnackBar('Distance log added successfully.');
    } catch (error) {
      _showSnackBar('Failed to save distance log: $error', success: false);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _submitMaintenance() async {
    if (!_maintenanceFormKey.currentState!.validate()) return;
    if (_selectedVehicleIdForMaintenance == null) {
      _showSnackBar('Select a vehicle for the maintenance record.', success: false);
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(garageRepositoryProvider);
      final title = _maintenanceTitleController.text.trim();

      await repo.addMaintenanceRecord(
        vehicleId: _selectedVehicleIdForMaintenance!,
        title: title,
        status: _maintenanceStatus,
        date: _maintenanceDate,
      );

      _maintenanceFormKey.currentState!.reset();
      _maintenanceDate = DateTime.now();
      _maintenanceDateController.text = DateFormat('yyyy-MM-dd').format(_maintenanceDate);

      _showSnackBar('Maintenance record added successfully.');
    } catch (error) {
      _showSnackBar('Failed to save maintenance record: $error', success: false);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Data to Firebase'),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: vehiclesAsync.when(
        data: (vehicles) => DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textMuted,
                tabs: [
                  Tab(text: 'Vehicle'),
                  Tab(text: 'Timeline'),
                  Tab(text: 'Distance'),
                  Tab(text: 'Maintenance'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildVehicleTab(),
                    _buildTimelineTab(vehicles),
                    _buildDistanceTab(vehicles),
                    _buildMaintenanceTab(vehicles),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (error, stack) => Center(child: Text('Error loading vehicles: $error', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildVehicleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _vehicleFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add New Vehicle', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(controller: _nameController, label: 'Vehicle Name', validator: _requiredValidator),
              _buildTextField(controller: _plateNumberController, label: 'Plate Number', validator: _requiredValidator),
              _buildTextField(controller: _batteryController, label: 'Battery %', keyboardType: TextInputType.number, validator: _batteryValidator),
              _buildTextField(controller: _locationController, label: 'Location', validator: _requiredValidator),
              _buildTextField(controller: _imageUrlController, label: 'Image URL (optional)', keyboardType: TextInputType.url),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: _isSaving ? null : _submitVehicle,
                child: _isSaving ? const CircularProgressIndicator(color: AppColors.textPrimary) : const Text('Save Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTab(List<Vehicle> vehicles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _timelineFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Timeline Event', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleIdForTimeline,
                decoration: _buildDecoration('Vehicle'),
                items: vehicles.map((vehicle) {
                  return DropdownMenuItem(
                    value: vehicle.id,
                    child: Text('${vehicle.name} (${vehicle.plateNumber})'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedVehicleIdForTimeline = value),
                validator: (value) => value == null ? 'Select a vehicle' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(controller: _timelineTitleController, label: 'Title', validator: _requiredValidator),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _timelineType,
                decoration: _buildDecoration('Type'),
                items: const [
                  DropdownMenuItem(value: 'maintenance', child: Text('maintenance')),
                  DropdownMenuItem(value: 'inspection', child: Text('inspection')),
                  DropdownMenuItem(value: 'charge', child: Text('charge')),
                ],
                onChanged: (value) => setState(() => _timelineType = value ?? 'maintenance'),
              ),
              const SizedBox(height: 12),
              _buildTextField(controller: _timelineMileageController, label: 'Mileage', keyboardType: TextInputType.number, validator: _requiredValidator),
              const SizedBox(height: 12),
              _buildDatePickerField(controller: _timelineDateController, label: 'Date', onTap: () => _pickDate(_timelineDateController, _timelineDate, (date) => _timelineDate = date)),
              const SizedBox(height: 12),
              _buildSliderField(label: 'Progress', value: _timelineProgress, onChanged: (value) => setState(() => _timelineProgress = value)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: _isSaving ? null : _submitTimeline,
                child: _isSaving ? const CircularProgressIndicator(color: AppColors.textPrimary) : const Text('Save Timeline Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceTab(List<Vehicle> vehicles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _distanceFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Distance Log', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleIdForDistance,
                decoration: _buildDecoration('Vehicle'),
                items: vehicles.map((vehicle) {
                  return DropdownMenuItem(
                    value: vehicle.id,
                    child: Text('${vehicle.name} (${vehicle.plateNumber})'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedVehicleIdForDistance = value),
                validator: (value) => value == null ? 'Select a vehicle' : null,
              ),
              const SizedBox(height: 12),
              _buildDatePickerField(controller: _distanceDateController, label: 'Date', onTap: () => _pickDate(_distanceDateController, _distanceDate, (date) => _distanceDate = date)),
              const SizedBox(height: 12),
              _buildTextField(controller: _distanceController, label: 'Distance (km)', keyboardType: TextInputType.number, validator: _requiredValidator),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: _isSaving ? null : _submitDistance,
                child: _isSaving ? const CircularProgressIndicator(color: AppColors.textPrimary) : const Text('Save Distance Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab(List<Vehicle> vehicles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _maintenanceFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Maintenance Record', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleIdForMaintenance,
                decoration: _buildDecoration('Vehicle'),
                items: vehicles.map((vehicle) {
                  return DropdownMenuItem(
                    value: vehicle.id,
                    child: Text('${vehicle.name} (${vehicle.plateNumber})'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedVehicleIdForMaintenance = value),
                validator: (value) => value == null ? 'Select a vehicle' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(controller: _maintenanceTitleController, label: 'Title', validator: _requiredValidator),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _maintenanceStatus,
                decoration: _buildDecoration('Status'),
                items: const [
                  DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                  DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                ],
                onChanged: (value) => setState(() => _maintenanceStatus = value ?? 'Upcoming'),
              ),
              const SizedBox(height: 12),
              _buildDatePickerField(controller: _maintenanceDateController, label: 'Date', onTap: () => _pickDate(_maintenanceDateController, _maintenanceDate, (date) => _maintenanceDate = date)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: _isSaving ? null : _submitMaintenance,
                child: _isSaving ? const CircularProgressIndicator(color: AppColors.textPrimary) : const Text('Save Maintenance Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _buildDecoration(label),
      validator: validator,
    );
  }

  InputDecoration _buildDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _buildDecoration(label),
      onTap: onTap,
      validator: _requiredValidator,
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: 1,
          divisions: 20,
          activeColor: AppColors.accent,
          inactiveColor: AppColors.divider,
        ),
        Text('${(value * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _batteryValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 100) {
      return 'Enter a battery percentage between 0 and 100';
    }
    return null;
  }
}
