import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F3953),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F3953), Color(0xFF326C7E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Rectangle
              Container(width: 390, height: 35, color: const Color(0xFFD9D9D9)),

              const SizedBox(height: 75), // Fixed Gap from Top
              // 2. SOS Button Area (Height removed to prevent overlapping)
              _buildSOSSection(context),

              // Divider Dots
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "● ● ●",
                  style: TextStyle(color: Color(0xFFE0B240), fontSize: 10),
                ),
              ),

              // 3. Grid Area - Using Expanded to ensure it fills available space
              // but remains fully visible without being cut off
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Center(
                    // Center ensures the grid is balanced vertically
                    child: Wrap(
                      spacing: 25,
                      runSpacing: 20,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildModeCard(
                          "Find a Mechanic",
                          Icons.build,
                          isFirst: true,
                        ),
                        _buildModeCard("Consult", Icons.add_to_photos),
                        _buildModeCard("Looking for?", Icons.search),
                        _buildModeCard(
                          "Look for Skilled Worker",
                          Icons.engineering,
                        ),
                        _buildModeCard(
                          "Gasoline Stations",
                          Icons.local_gas_station,
                        ),
                        _buildModeCard(
                          "More",
                          Icons.more_horiz,
                          isComingSoon: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. THE 72PX GAP (Between containers and Ads)
              const SizedBox(height: 72),

              // 5. Fixed Ads Area
              Container(
                width: 356,
                height: 100,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Center(
                  child: Text(
                    "Ads Area",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              // Fixed Bottom Nav
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOSSection(BuildContext context) {
    return Container(
      width: 390,
      // Removed height: 189 here so it acts like a fixed button area
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1AE0B240), width: 1)),
      ),
      child: Center(
        child: GestureDetector(
          onTap: () => debugPrint("Navigate to Vehicle Selection Page"),
          child: Container(
            width: 130,
            height: 130,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFF27070), Color(0xFFB23A3A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x63422F00),
                  offset: Offset(2, 1),
                  blurRadius: 5,
                ),
              ],
            ),

            child: const Center(
              child: Text(
                "SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    String label,
    IconData icon, {
    bool isFirst = false,
    bool isComingSoon = false,
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isComingSoon ? const Color(0xFF0C1221) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(4, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: isComingSoon
              ? const Center(
                  child: Text(
                    "COMING\nSOON",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                )
              : Icon(icon, size: 40, color: const Color(0xFF2F3953)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 2.0,
              letterSpacing: 0.15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5BC),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home, "Home", isSelected: true),
          _navItem(Icons.history, "Activity"),
          _navItem(Icons.mail, "Messages"),
          _navItem(Icons.person, "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF2F3953) : Colors.black54,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 2.0,
            letterSpacing: 0.15,
            color: isSelected ? const Color(0xFF2F3953) : Colors.black,
          ),
        ),
      ],
    );
  }
}
