import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/62066279?v=4'), // Your GitHub avatar
                ),
                const SizedBox(height: 16),
                Text("Pedro Victor Veras", style: Get.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text("pedrov12@example.com", style: Get.textTheme.titleMedium), // Placeholder email
                const SizedBox(height: 16),
                const Text(
                  "Software Engineer | Electrical Engineer | Passionate about Flutter, Python, and AI. Always learning and building!",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Social media icons (add real images and URL launcher logic here)
                // IconButton(
                //   icon: Image.asset('assets/github_logo.png', height: 30),
                //   onPressed: () {
                //     // TODO: Implement URL launcher for GitHub profile
                //   },
                // ),
                // IconButton(
                //   icon: Image.asset('assets/linkedin_logo.png', height: 30),
                //   onPressed: () {
                //     // TODO: Implement URL launcher for LinkedIn profile
                //   },
                // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}