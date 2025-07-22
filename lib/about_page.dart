import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About BITS Connect")),
      backgroundColor: const Color(0xFFF9F9FB),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "🙏 Waheguru Ji Ka Khalsa",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
      SizedBox(height: 4), // spacing between lines
      Text(
        "Waheguru Ji Ki Fateh!",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    ],
  ),
),
              const SizedBox(height: 10),
              const Text(
                "With utmost gratitude to Waheguru Ji for giving the strength, clarity, and inspiration to build this app. May it serve students well and foster a culture of unity, learning, and shared purpose.",
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                "📚 What is BITS Connect?",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
  "BITS Connect is your personalized platform to make studying more effective and enjoyable by connecting with like-minded peers on campus.\n\n"
  "• PYQ Practice:\nPerfect for collaborative last-minute prep — join groups focused on solving previous year questions before exams.\n\n"
  "• Class Discussion:\nMissed a class? Confused about a topic? Join discussions with students from your enrolled courses to clear concepts together.\n\n"
  "• Silent Study:\nNeed a distraction-free study space? Join or create a silent study group to study independently but in a group setting.\n\n"
  "• All Groups:\nBrowse all active, upcoming, and permanent study groups on campus. Filter based on your needs and course alignment.\n\n"
  "• Event Space:\nHop into casual sessions, chill meetups, or spontaneous jam rooms happening around campus.\n\n"
  "• Junior–Senior Interaction:\nFreshie? Chat with seniors, get survival tips, and make some fun connections beyond the books.\n\n"
  "Whether you're prepping for exams, catching up on lectures, or just looking to vibe with others — BITS Connect helps you find the right peers, at the right time, in the right place.\n\n"
  "Study the Lite Way. ⚡",
  style: TextStyle(fontSize: 16),
),
              const Divider(height: 40),
              Text(
                "👨‍💻 About the Creator",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Name: Bhuvan Arora\n"
                "BITS ID: 2023A7PS0246P\n"
                "BITS Mail: f20230246@pilani.bits-pilani.ac.in\n"
                "Contact: 7976440922",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                "This app is built with ❤️ by a BITSian, for BITSians.\nYour feedback, suggestions, or collaboration ideas are always welcome!",
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}