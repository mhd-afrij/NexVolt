import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/vehicle_model.dart';
import '../providers/account_provider.dart';

/// Add a new vehicle or edit an existing one.
/// Pass [vehicle] for edit mode; omit for add mode.
class AddEditVehicleScreen extends StatefulWidget {
  final VehicleModel? vehicle;
  const AddEditVehicleScreen({super.key, this.vehicle});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _capacityCtrl;
  late TextEditingController _batteryPctCtrl;

  String _vehicleType = 'Sedan';
  String _connectorType = 'Type 2';
  bool _saving = false;

  static const _vehicleTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Van',
    'Bus',
    'Motorcycle',
    'Other',
  ];

  static const _connectorTypes = [
    'Type 1',
    'Type 2',
    'CCS',
    'CHAdeMO',
    'Tesla',
    'GB/T',
  ];

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _brandCtrl = TextEditingController(text: v?.brand ?? '');
    _companyCtrl = TextEditingController(text: v?.company ?? '');
    _modelCtrl = TextEditingController(text: v?.model ?? '');
    _capacityCtrl = TextEditingController(
      text: v != null ? v.batteryCapacityKWh.toString() : '',
    );
    _batteryPctCtrl = TextEditingController(
      text: v != null ? v.currentBatteryPercentage.toString() : '',
    );
    if (v != null) {
      _vehicleType = v.vehicleType;
      _connectorType = v.connectorType;
    }
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _companyCtrl.dispose();
    _modelCtrl.dispose();
    _capacityCtrl.dispose();
    _batteryPctCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<AccountProvider>();
    final now = DateTime.now();

    final vehicle = VehicleModel(
      vehicleId: widget.vehicle?.vehicleId ?? '',
      userId: '', // Provider will fill userId for add
      brand: _brandCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      vehicleType: _vehicleType,
      batteryCapacityKWh: double.parse(_capacityCtrl.text.trim()),
      connectorType: _connectorType,
      currentBatteryPercentage: double.parse(_batteryPctCtrl.text.trim()),
      createdAt: widget.vehicle?.createdAt ?? now,
    );

    final success = _isEditing
        ? await provider.updateVehicle(vehicle)
        : await provider.addVehicle(vehicle);

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Vehicle updated' : 'Vehicle added successfully',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Operation failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                'Brand',
                'e.g. Tesla',
                _brandCtrl,
                icon: Icons.branding_watermark_outlined,
              ),
              const SizedBox(height: 14),
              _field(
                'Company',
                'e.g. Tesla Motors',
                _companyCtrl,
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 14),
              _field(
                'Model',
                'e.g. Model 3',
                _modelCtrl,
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: 14),

              // Vehicle Type dropdown
              DropdownButtonFormField<String>(
                value: _vehicleType,
                decoration: _inputDec('Vehicle Type', Icons.category_outlined),
                items: _vehicleTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _vehicleType = v);
                },
              ),
              const SizedBox(height: 14),

              // Battery capacity
              TextFormField(
                controller: _capacityCtrl,
                decoration: _inputDec(
                  'Battery Capacity (kWh)',
                  Icons.battery_full_rounded,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Battery capacity is required';
                  }
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) {
                    return 'Enter a valid capacity in kWh';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Connector type dropdown
              DropdownButtonFormField<String>(
                value: _connectorType,
                decoration: _inputDec(
                  'Connector Type',
                  Icons.electrical_services_rounded,
                ),
                items: _connectorTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _connectorType = v);
                },
              ),
              const SizedBox(height: 14),

              // Current battery percentage
              TextFormField(
                controller: _batteryPctCtrl,
                decoration: _inputDec(
                  'Current Battery (%)',
                  Icons.battery_charging_full_rounded,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final val = double.tryParse(v);
                  if (val == null || val < 0 || val > 100) {
                    return 'Must be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Update Vehicle' : 'Add Vehicle',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController ctrl, {
    required IconData icon,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDec(label, icon).copyWith(hintText: hint),
      textCapitalization: TextCapitalization.words,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label is required';
        return null;
      },
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }
}
