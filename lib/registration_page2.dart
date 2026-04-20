import 'package:flutter/material.dart';
import 'registration_page3.dart';

class VehicleEntry {
  final String plate;
  final String year;
  final String make;
  final String model;
  final String type;
  final String? vehicleImageUrl;
  final String? plateImageUrl;

  VehicleEntry({
    required this.plate,
    required this.year,
    required this.make,
    required this.model,
    required this.type,
    this.vehicleImageUrl,
    this.plateImageUrl,
  });
}

class RegistrationPage2 extends StatefulWidget {
  final bool isEulaAccepted;
  final String fullName; // New parameter to receive full name from page 1
  final String username;
  final String phoneNumber;

  const RegistrationPage2({
    super.key,
    required this.isEulaAccepted,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
  });

  @override
  State<RegistrationPage2> createState() => _RegistrationPage2State();
}

class _RegistrationPage2State extends State<RegistrationPage2> {
  final List<VehicleEntry> _queuedVehicles = [];
  // Variable ng Checkboxes
  bool _isMotorcycle = false;
  bool _isPrivateCar = false;
  bool _isBoth = false;

  bool _isFormValid =
      false; // To track if the form is valid for enabling the Continue button

  // capture vehicle details
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // listener so the button responds to changes in the checkboxes
    _plateController.addListener(_validateForm);
    _yearController.addListener(_validateForm);
    _makeController.addListener(_validateForm);
    _modelController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      // Logic: At least one vehicle type selected AND all text fields filled
      bool vehicleTypeSelected = _isMotorcycle || _isPrivateCar || _isBoth;
      bool fieldsFilled =
          _plateController.text.trim().isNotEmpty &&
          _yearController.text.trim().isNotEmpty &&
          _makeController.text.trim().isNotEmpty &&
          _modelController.text.trim().isNotEmpty;

      _isFormValid = vehicleTypeSelected && fieldsFilled;
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    _yearController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF2F3953), Color(0xFF326C7E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                color: const Color(0xFF2F3953),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFFE0B240),
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Vehicle Type Checkboxes
                      Row(
                        children: [
                          _buildCheckbox("Motorcycle", _isMotorcycle, (val) {
                            setState(() {
                              _isMotorcycle = val!;
                              if (!_isMotorcycle) {
                                _isBoth = false; // This is good
                              }
                              if (_isMotorcycle && _isPrivateCar) {
                                _isBoth =
                                    true; // Add this logic // to auto-check "Both" if both types are selected
                              }
                              _validateForm();
                            });
                          }),
                          const SizedBox(width: 10),
                          _buildCheckbox("Private Car", _isPrivateCar, (val) {
                            setState(() {
                              _isPrivateCar = val!;
                              if (!_isPrivateCar) _isBoth = false;
                              _validateForm();
                            });
                          }),
                        ],
                      ),

                      //Both Checkbox
                      _buildCheckbox("Both?", _isBoth, (val) {
                        setState(() {
                          _isBoth = val!;
                          if (_isBoth) {
                            _isMotorcycle = true;
                            _isPrivateCar = true;
                          }
                          _validateForm();
                        });
                      }),

                      const SizedBox(height: 20),

                      // input fields
                      _buildVehicleInput(
                        "Plate Number",
                        "ABC 123",
                        _plateController,
                      ),
                      _buildVehicleInput(
                        "Vehicle Year",
                        "2000",
                        _yearController,
                      ),
                      _buildVehicleInput(
                        "Vehicle Make",
                        "Toyota",
                        _makeController,
                      ),
                      _buildVehicleInput(
                        "Vehicle Model",
                        "Innova",
                        _modelController,
                      ),

                      const SizedBox(height: 40),

                      // Bottom Buttons (Back and Continue)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton("Back", isSecondary: true),
                          _buildActionButton("Continue"),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Checkbox styles
  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFE0B240),
          checkColor: Colors.black,
          side: const BorderSide(color: Color(0xFFE0B240), width: 2),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // input fields shadow and design
  Widget _buildVehicleInput(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE0B240),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFFF),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Color(0xFFE0B240), offset: Offset(4, 4)),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: label == "Vehicle Year"
                  ? TextInputType.number
                  : TextInputType.text, // Updated keyboard type for year
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFB1B0B0),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action buttons with design
  Widget _buildActionButton(String text, {bool isSecondary = false}) {
    bool isEnabled = text == "Continue" ? _isFormValid : true;

    return GestureDetector(
      onTap: isEnabled
          ? () async {
              if (text == "Back") {
                Navigator.pop(context);
              } else if (text == "Continue") {
                // 1. Create the VehicleEntry object from CURRENT screen data
                VehicleEntry currentVehicle = VehicleEntry(
                  plate: _plateController.text.trim().toUpperCase(),
                  year: _yearController.text.trim(),
                  make: _makeController.text.trim(),
                  model: _modelController.text.trim(),
                  type: _isBoth
                      ? "Both"
                      : (_isMotorcycle ? "Motorcycle" : "Private Car"),
                );

                // 2. Navigate to Page 3 passing the FULL RELAY of data
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationPage3(
                      // DATA FROM EULA & PAGE 1
                      isEulaAccepted: widget.isEulaAccepted,
                      fullName: widget.fullName,
                      username: widget.username,
                      phoneNumber: widget.phoneNumber,
                      // DATA FROM THIS PAGE (PAGE 2)
                      currentVehicle: currentVehicle,
                    ),
                  ),
                );

                // 3. Logic for "Add Another Vehicle" loop
                // If Page 3 returns 'true', it means the user clicked "Add Another"
                if (result is Map<String, String>) {
                  setState(() {
                    // Add the vehicle to the queue, but this time WITH the URLs
                    _queuedVehicles.add(
                      VehicleEntry(
                        plate: currentVehicle.plate,
                        year: currentVehicle.year,
                        make: currentVehicle.make,
                        model: currentVehicle.model,
                        type: currentVehicle.type,
                        vehicleImageUrl:
                            result['vUrl'], // This is the Cloud URL
                        plateImageUrl: result['pUrl'], // This is the Cloud URL
                      ),
                    );

                    // Clear fields for the next vehicle entry
                    _plateController.clear();
                    _yearController.clear();
                    _makeController.clear();
                    _modelController.clear();
                    _isMotorcycle = false;
                    _isPrivateCar = false;
                    _isBoth = false;
                  });
                }
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        height: 45,
        decoration: BoxDecoration(
          color: isEnabled
              ? (isSecondary
                    ? const Color(0xFF2F3953)
                    : const Color(0xFFE0B240))
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: isSecondary ? Border.all(color: Colors.white24) : null,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isEnabled
                  ? (isSecondary ? Colors.white : Colors.black)
                  : Colors.white24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
