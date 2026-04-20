import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'registration_page2.dart';

class RegistrationPage3 extends StatefulWidget {
  final bool isEulaAccepted;
  final String fullName;
  final String username;
  final String phoneNumber;
  final VehicleEntry currentVehicle;

  const RegistrationPage3({
    super.key,
    required this.isEulaAccepted,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    required this.currentVehicle,
  });

  @override
  State<RegistrationPage3> createState() => _RegistrationPage3State();
}

class _RegistrationPage3State extends State<RegistrationPage3> {
  final List<File?> _mediaFiles = [null, null, null, null];
  final ImagePicker _picker = ImagePicker();
  bool _isVerifying = false;
  String? docId;

  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    int matches = 0;
    for (int i = 0; i < s1.length && i < s2.length; i++) {
      if (s1[i] == s2[i]) matches++;
    }
    return matches / (s1.length > s2.length ? s1.length : s2.length);
  }

  Future<bool> _verifySelfie(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );
    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      if (faces.isEmpty) return false;
      final face = faces.first;
      if (face.boundingBox.height < 150) return false;
      if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() > 25) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      await faceDetector.close();
    }
  }

  Future<bool> _isNotSelfie(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      return faces.isEmpty;
    } catch (e) {
      return false;
    } finally {
      await faceDetector.close();
    }
  }

  Future<bool> _isVehicle(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
    try {
      final List<ImageLabel> labels = await imageLabeler.processImage(
        inputImage,
      );
      //blacklist
      final negativeKeywords = ['toy', 'robot', 'printer', 'furniture'];
      for (ImageLabel label in labels) {
        final String text = label.label.toLowerCase();
        if (negativeKeywords.any((no) => text.contains(no))) return false;
        //whitelist
        if (text.contains('car') ||
            text.contains('vehicle') ||
            text.contains('land vehicle') ||
            text.contains('motorcycle') ||
            text.contains("scooter")) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      await imageLabeler.close();
    }
  }

  Future<bool> _verifyText(
    File imageFile,
    List<String> keywords, {
    bool isPlate = false,
    bool checkName = false,
  }) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      String rawText = recognizedText.text.toUpperCase().replaceAll('\n', ' ');
      if (checkName) {
        List<String> nameParts = widget.fullName.toUpperCase().split(' ');
        int matches = 0;
        for (var part in nameParts) {
          if (part.length > 2 && rawText.contains(part)) matches++;
        }
        if (matches < (nameParts.length > 1 ? 2 : 1)) return false;
      }
      if (isPlate) {
        String cleanOCR = rawText.replaceAll(RegExp(r'[\s\-]'), '');
        String cleanInput = widget.currentVehicle.plate.replaceAll(
          RegExp(r'[\s\-]'),
          '',
        );
        return cleanOCR.contains(cleanInput) ||
            _calculateSimilarity(cleanInput, cleanOCR) > 0.9;
      }
      return keywords.isEmpty ||
          keywords.any((k) => rawText.contains(k.toUpperCase()));
    } catch (e) {
      return false;
    } finally {
      await textRecognizer.close();
    }
  }

  // --- CORE LOGIC ---

  Future<void> _pickMedia(int index) async {
    ImageSource? source = (index == 0)
        ? await _showSourcePicker()
        : ImageSource.camera;
    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      preferredCameraDevice: (index == 1)
          ? CameraDevice.front
          : CameraDevice.rear,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _isVerifying = true);
      File file = File(pickedFile.path);
      bool ok = false;
      if (index == 0) {
        ok = await _verifyText(file, [
          "PHILIPPINES",
          "REPUBLIC",
          "IDENTITY",
          "POSTAL",
          "UMID",
          "PHILSYS",
          "SSS",
          "DRIVER",
          "LICENSE",
        ], checkName: true);
      } else if (index == 1) {
        ok = await _verifySelfie(file);
      } else if (index == 2) {
        ok = await _isNotSelfie(file) && await _isVehicle(file);
      } else if (index == 3) {
        ok =
            await _isNotSelfie(file) &&
            await _verifyText(file, [], isPlate: true);
      }

      setState(() {
        _isVerifying = false;
        if (ok) {
          _mediaFiles[index] = file;
        } else {
          _showErrorSnackBar("Verification failed. Please try again.");
        }
      });
    }
  }

  Future<String> _uploadSingleFile(File file, String name) async {
    docId ??= "user_${DateTime.now().millisecondsSinceEpoch}";
    final task = await FirebaseStorage.instance
        .ref('uploads/$docId/$name.jpg')
        .putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> _handleFinalSubmission() async {
    if (_mediaFiles.contains(null)) {
      _showErrorSnackBar("Please complete all 4 requirements.");
      return;
    }

    setState(() => _isVerifying = true);
    try {
      String idUrl = await _uploadSingleFile(_mediaFiles[0]!, "identity_id");
      String selfieUrl = await _uploadSingleFile(_mediaFiles[1]!, "selfie");
      String vUrl = await _uploadSingleFile(
        _mediaFiles[2]!,
        "veh_${widget.currentVehicle.plate}",
      );
      String pUrl = await _uploadSingleFile(
        _mediaFiles[3]!,
        "plate_${widget.currentVehicle.plate}",
      );

      await FirebaseFirestore.instance
          .collection('registrations')
          .doc(docId)
          .set({
            'fullName': widget.fullName,
            'username': widget.username,
            'phone': widget.phoneNumber,
            'eulaAccepted': widget.isEulaAccepted,
            'identityUrl': idUrl,
            'selfieUrl': selfieUrl,
            'vehicles': [
              {
                'plate': widget.currentVehicle.plate,
                'make': widget.currentVehicle.make,
                'model': widget.currentVehicle.model,
                'year': widget.currentVehicle.year,
                'type': widget.currentVehicle.type,
                'vehicleImageUrl': vUrl,
                'plateImageUrl': pUrl,
              },
            ],
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
      _showSuccessDialog(context);
    } catch (e) {
      _showErrorSnackBar("Final upload failed. Please try again.");
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2F3953), Color(0xFF326C7E)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE0B240),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          _buildMediaCard("Upload a Valid ID", 0),
                          _buildMediaCard("Take a selfie", 1),
                          _buildMediaCard("Take a picture of the vehicle", 2),
                          _buildMediaCard(
                            "Take a picture of the plate number",
                            3,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton("Back", isSecondary: true),
                              _buildActionButton("Finish"),
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
          if (_isVerifying)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE0B240)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(String label, int index) {
    bool hasFile = _mediaFiles[index] != null;
    return GestureDetector(
      onTap: () => _pickMedia(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: hasFile
                  ? Image.file(
                      _mediaFiles[index]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : const Icon(Icons.image, size: 50, color: Colors.black26),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF2D4B73),
                padding: const EdgeInsets.all(8),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (hasFile)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.check_circle, color: Colors.green, size: 30),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, {bool isSecondary = false}) {
    bool isEnabled = (text == "Finish") ? !_mediaFiles.contains(null) : true;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? (isSecondary ? Colors.transparent : const Color(0xFFE0B240))
            : Colors.grey,
        side: isSecondary ? const BorderSide(color: Color(0xFFE0B240)) : null,
      ),
      onPressed: isEnabled
          ? () => (text == "Finish")
                ? _handleFinalSubmission()
                : Navigator.pop(context)
          : null,
      child: Text(
        text,
        style: TextStyle(color: isSecondary ? Colors.white : Colors.black),
      ),
    );
  }

  Future<ImageSource?> _showSourcePicker() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Camera"),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Gallery"),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(m),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF2F3953),
        title: const Text("Success", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Registration submitted successfully.",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text("OK", style: TextStyle(color: Color(0xFFE0B240))),
          ),
        ],
      ),
    );
  }
}
