import 'package:flutter/material.dart';
import 'registration_page2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage1 extends StatefulWidget {
  final bool isEulaAccepted;

  const RegistrationPage1({super.key, required this.isEulaAccepted});

  @override
  State<RegistrationPage1> createState() => _RegistrationPage1State();
}

class _RegistrationPage1State extends State<RegistrationPage1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isFormValid = false;
  bool _isPasswordVisible = false;
  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;
  bool _isPhoneAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);

    _usernameController.addListener(() {
      _checkUsernameAvailability(_usernameController.text.trim());
      _validateForm();
    });

    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    _phoneController.addListener(() {
      if (_phoneController.text.length == 11) {
        _checkPhoneAvailability(_phoneController.text.trim());
      }
      _validateForm();
    });

    _emailController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
  }

  // firestore will check for dups
  Future<void> _checkUsernameAvailability(String username) async {
    final queryName = username.trim().toLowerCase();
    if (queryName.isEmpty) {
      setState(() => _isUsernameAvailable = true);
      return;
    }

    setState(() => _isCheckingUsername = true);

    try {
      // Single query is enough
      final result = await FirebaseFirestore.instance
          .collection('registrations')
          .where('username', isEqualTo: queryName)
          .get();

      setState(() {
        _isUsernameAvailable = result.docs.isEmpty;
        _isCheckingUsername = false;
      });

      _validateForm();
    } catch (e) {
      debugPrint("Error checking username: $e");
      setState(() => _isCheckingUsername = false);
    }
  }

  Future<void> _checkPhoneAvailability(String phone) async {
    if (phone.isEmpty) return;

    final result = await FirebaseFirestore.instance
        .collection('registrations')
        .where('phone', isEqualTo: phone.trim())
        .get();

    setState(() {
      _isPhoneAvailable = result.docs.isEmpty;
    });

    _validateForm();
  }

  void _validateForm() {
    // email and phone validation regex patterns
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^09\d{9}$');

    setState(() {
      _isFormValid =
          _nameController.text.trim().isNotEmpty &&
          _usernameController.text.trim().isNotEmpty &&
          _isUsernameAvailable &&
          _isPhoneAvailable &&
          _passwordController.text.length >=
              6 && // PW must be 6 or more characters
          (_passwordController.text == _confirmPasswordController.text) &&
          _addressController.text.trim().isNotEmpty &&
          emailRegex.hasMatch(_emailController.text.trim()) &&
          phoneRegex.hasMatch(_phoneController.text.trim());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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
                    children: [
                      const SizedBox(height: 10),
                      _buildRegistrationInput(
                        "Complete Name",
                        "First Name Last Name",
                        _nameController,
                      ),
                      _buildRegistrationInput(
                        "Username",
                        "Juan234",
                        _usernameController,
                      ),

                      // user availability
                      if (!_isUsernameAvailable &&
                          _usernameController.text.isNotEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15, left: 5),
                            child: Text(
                              "✕ Username already taken",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      _buildRegistrationInput(
                        "Password",
                        "Password123",
                        _passwordController,
                        obscureText: !_isPasswordVisible,
                        isPasswordField: true,
                      ),
                      _buildRegistrationInput(
                        "Confirm Password",
                        "Password123",
                        _confirmPasswordController,
                        obscureText: !_isPasswordVisible,
                        isPasswordField: true,
                      ),

                      if (_passwordController.text.isNotEmpty &&
                          _passwordController.text.length < 6)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            " X Password must be at least 6 characters",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      if (_passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty &&
                          _passwordController.text !=
                              _confirmPasswordController.text)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Passwords do not match",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      _buildRegistrationInput(
                        "Phone Number",
                        "09123456789",
                        _phoneController,
                        keyboardType: TextInputType.phone,
                      ),

                      if (_phoneController.text.isNotEmpty &&
                          !_phoneController.text.startsWith("09"))
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15, left: 5),
                          child: Text(
                            "✕ Phone number must start with 09",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (_phoneController.text.isNotEmpty &&
                          _phoneController.text.length != 11)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15, left: 5),
                          child: Text(
                            "✕ Must be exactly 11 digits",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (!_isPhoneAvailable &&
                          _phoneController.text.length == 11)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15, left: 5),
                          child: Text(
                            "✕ This phone number is already registered",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      _buildRegistrationInput(
                        "Email",
                        "juan.dela.cruz@example.com",
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildRegistrationInput(
                        "Physical Address",
                        "Placeholder",
                        _addressController,
                      ),
                      const SizedBox(height: 20),
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

  // builder for input fields with validation and password visibility toggle
  Widget _buildRegistrationInput(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
    bool isPasswordField = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
              color: const Color(0xFFF0FFFF).withAlpha(230),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Color(0xFFE0B240), offset: Offset(3, 3)),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
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
                suffixIcon: isPasswordField
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, {bool isSecondary = false}) {
    // username availability
    bool isButtonEnabled = text == "Continue"
        ? (_isFormValid && !_isCheckingUsername)
        : true;

    return GestureDetector(
      onTap: isButtonEnabled
          ? () {
              if (text == "Back") {
                Navigator.pop(context);
              } else if (text == "Continue") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationPage2(
                      isEulaAccepted:
                          widget.isEulaAccepted, // Forward the EULA status
                      fullName: _nameController.text.trim(),
                      username: _usernameController.text.trim().toLowerCase(),
                      phoneNumber: _phoneController.text.trim(),
                    ),
                  ),
                );
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        height: 45,
        decoration: BoxDecoration(
          color: isButtonEnabled
              ? (isSecondary
                    ? const Color(0xFF2F3953)
                    : const Color(0xFFE0B240))
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: isSecondary ? Border.all(color: Colors.white24) : null,
          boxShadow: isButtonEnabled
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
              color: isButtonEnabled
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
