import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HardwareSolutionPage extends StatefulWidget {
  const HardwareSolutionPage({super.key});

  @override
  State<HardwareSolutionPage> createState() => _HardwareSolutionPageState();
}

class _HardwareSolutionPageState extends State<HardwareSolutionPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);

  int _selectedTabIndex = 0;
  final List<String> _tabs = ["Schematic", "Board Layout", "Diode Value", "IC Pinout", "Component"];

  // Dummy scale untuk interaksi zoom
  double _scale = 1.0;
  final TransformationController _transformationController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text(
              "Hardware Solution",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              "iPhone 13 Pro Max",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                bool isSelected = _selectedTabIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                      _scale = 1.0; // reset zoom
                      _transformationController.value = Matrix4.identity();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? _primaryBlue : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? _primaryBlue : Colors.grey.shade500,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Viewer Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF222222), // Dark background for schematic
              child: Stack(
                children: [
                  // Dummy Content Image (Interactive Viewer)
                  Center(
                    child: GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          _scale = _scale == 1.0 ? 2.0 : 1.0;
                          _transformationController.value = Matrix4.diagonal3Values(_scale, _scale, 1.0);
                        });
                      },
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 1.0,
                        maxScale: 5.0,
                        onInteractionUpdate: (details) {
                          // Dummy update
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          margin: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: Stack(
                            children: [
                              // Placeholder grid/image
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: GridPainter(),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedTabIndex == 0 ? Icons.schema_rounded 
                                      : _selectedTabIndex == 1 ? Icons.memory_rounded 
                                      : Icons.electrical_services_rounded,
                                      size: 100, 
                                      color: Colors.white24,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Data ${_tabs[_selectedTabIndex]} Dimuat",
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "(Gunakan cubitan untuk zoom in/out)",
                                      style: TextStyle(
                                        color: Colors.white30,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Zoom Controls overlay
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Column(
                      children: [
                        _buildControlButton(Icons.add_rounded, () {
                          setState(() {
                            _scale = (_scale + 0.5).clamp(1.0, 5.0);
                          });
                        }),
                        const SizedBox(height: 8),
                        _buildControlButton(Icons.remove_rounded, () {
                          setState(() {
                            _scale = (_scale - 0.5).clamp(1.0, 5.0);
                          });
                        }),
                        const SizedBox(height: 8),
                        _buildControlButton(Icons.fit_screen_rounded, () {
                          setState(() {
                            _scale = 1.0;
                          });
                        }),
                      ],
                    ),
                  ),
                  
                  // Selection Info overlay
                  if (_selectedTabIndex == 1 || _selectedTabIndex == 2)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selected Component: U3100",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "VCC_MAIN",
                              style: TextStyle(color: Colors.red.shade400, fontSize: 11),
                            ),
                            if (_selectedTabIndex == 2) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Diode: 0.345v",
                                style: const TextStyle(color: Colors.green, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// Dummy grid for aesthetic
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
