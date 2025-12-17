import 'package:flutter/material.dart';
import 'package:smart_video_downloader/pages/testPage.dart';
import 'package:smart_video_downloader/pages/VideoDownloaderPage.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final List<Widget> _pages = [
    const VideoDownloaderPage(),
    const TestPage(),
    const TestPage(),
    const TestPage(),
  ];

  void _onItemTapped(int index) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _pages[index],
    ),
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF4A90A4), // Deep teal blue
      elevation: 2,
      title: const Text(
        'Menu',
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7FB3D3), // Light blue
            Color(0xFFB8E6B8), // Light green
          ],
        ),
      ),
      // color: Color(0xFF7FB3D3),
      padding: const EdgeInsets.all(20),
      child: Center(

      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2, 
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildOptionCard(
            icon: Icons.video_library,
            title: 'Videos',
            onTap: () => _onItemTapped(0),
          ),
          _buildOptionCard(
            icon: Icons.lock_clock,
            title: 'Test',
            onTap: () => _onItemTapped(1),
          ),
          _buildOptionCard(
            icon: Icons.account_box_outlined,
            title: 'Test',
            onTap: () => _onItemTapped(2),
          ),
          _buildOptionCard(
            icon: Icons.settings,
            title: 'Test',
            onTap: () => _onItemTapped(3),
          ),
        ],
      ),
    ),
  ),
);
}
}

Widget _buildOptionCard({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color.fromARGB(255, 111, 184, 199),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
