import 'package:flutter/material.dart';
import 'registration_page1.dart';

class EulaPage extends StatefulWidget {
  const EulaPage({super.key});

  @override
  State<EulaPage> createState() => _EulaPageState();
}

class _EulaPageState extends State<EulaPage> {
  bool _isAccepted = false; // Tracks the EULA checkbox status

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
        child: Stack(
          children: [
            // EULA Layer
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60), // Space for the back arrow
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "End User License Agreement (EULA)",
                            style: TextStyle(
                              color: Color(0xFFE0B240),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildEulaText(
                            "This End User License Agreement (\"Agreement\") is a legal contract between you (\"User\") and ZS Studios (\"Company\"). By installing, accessing, or using the LARA (the \"System\"), you agree to be bound by these terms. If you do not agree, do not install or use the System.",
                          ),
                          _buildSectionTitle("1. SCOPE OF LICENSE"),
                          _buildEulaText(
                            "The Company grants you a revocable, non-exclusive, non-transferable, limited license to use the System for personal or authorized real-time assistance purposes within the Republic of the Philippines.",
                          ),
                          _buildSectionTitle(
                            "2. DATA PRIVACY & CONSENT (R.A. 10173)",
                          ),
                          _buildEulaText(
                            "In compliance with the Philippine Data Privacy Act of 2012, you provide express and \"informed consent\" for the collection and processing of the following information:\n\n"
                            "• Identity Data: Full name, mobile number, home/office address, and government-issued ID details if required.\n"
                            "• Media: Real-time photos and uploaded images for identity verification and incident reporting.\n"
                            "• Location Data: Continuous real-time GPS tracking (including background location) to provide location-aware assistance.\n"
                            "• Vehicle Data: Plate number, conduction sticker, make, model, color, and real-time diagnostic/speed data.",
                          ),
                          _buildSectionTitle("3. USER OBLIGATIONS & SAFETY"),
                          _buildEulaText(
                            "Accuracy: You must provide truthful and updated information.\n\n"
                            "Road Safety: In accordance with the Anti-Distracted Driving Act (R.A. 10913), you must not manually operate this System while driving.\n\n"
                            "Lawful Use: You may not use the System to monitor any individual without their explicit legal consent.",
                          ),
                          _buildSectionTitle(
                            "4. PROHIBITED CONDUCT & CRIMINAL SANCTIONS",
                          ),
                          _buildEulaText(
                            "The Company maintains a zero-tolerance policy for misuse. Violation of these terms may result in immediate account termination and criminal prosecution under the Cybercrime Prevention Act (R.A. 10175):\n\n"
                            "• Identity Theft: Using another person's name or vehicle details is punishable by up to 12 years imprisonment.\n"
                            "• Computer-Related Fraud: Providing false data will be reported to the NBI or PNP Anti-Cybercrime Group.",
                          ),
                          _buildSectionTitle("5. DATA SECURITY & DISCLOSURE"),
                          _buildEulaText(
                            "We implement security measures to protect your data. We may disclose information to Emergency Responders or Law Enforcement when presented with a valid warrant.",
                          ),
                          _buildSectionTitle("6. LIMITATION OF LIABILITY"),
                          _buildEulaText(
                            "The Company provides the System \"as-is.\" We are not liable for delays caused by network congestion or inaccuracies in GPS data.",
                          ),
                          _buildSectionTitle("7. TERMINATION"),
                          _buildEulaText(
                            "The Company reserves the right to terminate your license immediately if you are suspected of fraudulent activity or identity theft.",
                          ),
                          _buildSectionTitle("8. GOVERNING LAW & VENUE"),
                          _buildEulaText(
                            "This Agreement is governed by the laws of the Republic of the Philippines.",
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "By Clicking on the continue button, you are accepting the End User License Agreement. Otherwise, you may close the software application.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _isAccepted,
                                onChanged: (val) =>
                                    setState(() => _isAccepted = val!),
                                activeColor: const Color(0xFFE0B240),
                                side: const BorderSide(color: Colors.white),
                              ),
                              const Text(
                                "I agree to the terms",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton("Back", isSecondary: true),
                              _buildActionButton("Continue"),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Back Arrow
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFE0B240)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE0B240),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildEulaText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
    );
  }

  // Back and continue button builder
  Widget _buildActionButton(String text, {bool isSecondary = false}) {
    // Your logic for enabling the button
    bool isButtonEnabled = text == "Continue" ? _isAccepted : true;

    return GestureDetector(
      onTap: isButtonEnabled
          ? () {
              if (text == "Back") {
                // must go back to registration page 2
                Navigator.pop(context);
              } else if (text == "Continue") {
                // must go to registration page 1 and send the value of _isAccepted
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RegistrationPage1(isEulaAccepted: true),
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
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isButtonEnabled
                  ? (isSecondary ? Colors.white : Colors.black)
                  : Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}
