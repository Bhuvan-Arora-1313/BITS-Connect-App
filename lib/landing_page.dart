import 'package:flutter/material.dart';
import 'my_groups_page.dart';
import 'chats_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'all_groups_page.dart';
import 'silent_study_groups_page.dart';
import 'pyq_page.dart';
import 'class_discussion_page.dart';
import 'about_page.dart';
import 'jrsr_page.dart';
import 'events_page.dart';

class StudyOption {
  final String label;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  StudyOption(this.label, this.imagePath, this.color, this.onTap);
}

class LandingPage extends StatelessWidget {
    final String uid;
  LandingPage({super.key,required this.uid});

  

  @override
  Widget build(BuildContext context) {
    final List<StudyOption> studyOptions = [
    StudyOption("PYQ Practice", "lib/assets/images/pyq.png", Colors.white, () {
      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PYQGroupsPage()),
  );
    }),
    StudyOption("Class Discussion", "lib/assets/images/class.png", Colors.white, () {
      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RegularClassDiscussionPage()),
  );
    }),
    StudyOption("All Groups", "lib/assets/images/all.png", Colors.white, () {
        Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AllGroupsPage()),
  );
    }),
    StudyOption("Silent Study", "lib/assets/images/silent.png", Colors.white, () {
      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SilentStudyGroupsPage()),
  );
    }),
    StudyOption("JR-SR Interaction", "lib/assets/images/jrsr.png", Colors.white, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => JrSrGroupsPage()),
  );
}),
StudyOption("Events", "lib/assets/images/events.png", Colors.white, () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EventsGroupsPage()),
  );
}),
  ];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Grid of buttons
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: studyOptions.map((option) {
                    return GestureDetector(
                      onTap: option.onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: option.color.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(option.imagePath),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              option.color.withOpacity(0.4),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                

                // Additional Navigation Buttons
                _buildNavigationButtons(context, uid),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, String uid) {
  final navOptions = [
    {
      "label": "My Groups",
      "icon": Icons.group,
      "onTap": () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyGroupsPage()),
        );
      }
    },
    // {
    //   "label": "Notifications",
    //   "icon": Icons.notifications,
    //   "onTap": () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => NotificationsPage(userId: uid)),
    //     );
    //   }
    // },
    {
      "label": "Profile",
      "icon": Icons.person,
      "onTap": () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
        );
      }
    },
    // {
    //   "label": "Settings",
    //   "icon": Icons.settings,
    //   "onTap": () {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("Settings coming soon!")),
    //     );
    //   }
    // },
    {
  "label": "About",
  "icon": Icons.info_outline,
  "onTap": () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }
},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: navOptions.map((option) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.white.withOpacity(0.85),
            foregroundColor: Colors.black87,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(option["icon"] as IconData),
          label: Text(
            option["label"] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: option["onTap"] as VoidCallback,
        ),
      );
    }).toList(),
  );
}
}