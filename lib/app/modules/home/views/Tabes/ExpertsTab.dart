import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import '../ExpertProfilePage.dart';

class Expertstab extends StatelessWidget {
  const Expertstab({super.key});

  final List<Map<String, dynamic>> _experts = const [
    {
      'name': 'Aditi Desai',
      'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
      'locationExpertise': 'Jaipur, Rajasthan',
      'title': 'Heritage Site Guide',
      'rating': 4.7,
      'ratingsCount': 124,
      'totalTravelers': 210,
      'itinerary': 'Day 1: Amber Fort, Day 2: Hawa Mahal',
      'languages': ['Hindi', 'English'],
      'price': '₹1499/day',
    },
    {
      'name': 'Raj Verma',
      'image': 'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=200',
      'locationExpertise': 'Udaipur, Rajasthan',
      'title': 'Lake City Travel Expert',
      'rating': 4.5,
      'ratingsCount': 98,
      'totalTravelers': 180,
      'itinerary': 'Day 1: City Palace, Day 2: Lake Pichola',
      'languages': ['Hindi', 'English'],
      'price': '₹1299/day',
    },
    {
      'name': 'Meena Kumari',
      'image': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
      'locationExpertise': 'Jodhpur, Rajasthan',
      'title': 'Cultural and Culinary Guide',
      'rating': 4.8,
      'ratingsCount': 135,
      'totalTravelers': 195,
      'itinerary': 'Day 1: Mehrangarh Fort, Day 2: Local cuisine tour',
      'languages': ['Hindi', 'Marwari', 'English'],
      'price': '₹1599/day',
    },
    {
      'name': 'Sanjay Rathore',
      'image': 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=200',
      'locationExpertise': 'Pushkar, Rajasthan',
      'title': 'Spiritual & Temple Guide',
      'rating': 4.6,
      'ratingsCount': 88,
      'totalTravelers': 160,
      'itinerary': 'Day 1: Brahma Temple, Day 2: Camel Safari',
      'languages': ['Hindi', 'Sanskrit', 'English'],
      'price': '₹1199/day',
    },
    {
      'name': 'Anita Joshi',
      'image': 'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
      'locationExpertise': 'Mount Abu, Rajasthan',
      'title': 'Hill Station Trek Expert',
      'rating': 4.9,
      'ratingsCount': 150,
      'totalTravelers': 220,
      'itinerary': 'Day 1: Dilwara Temples, Day 2: Guru Shikhar Trek',
      'languages': ['Hindi', 'Gujarati', 'English'],
      'price': '₹1399/day',
    },
    {
      'name': 'Tanya Chauhan',
      'image': 'https://images.unsplash.com/photo-1542909168-82c3e7fdca5c?w=200',
      'locationExpertise': 'Manali, Himachal Pradesh',
      'title': 'Mountain & Snow Activity Guide',
      'rating': 4.7,
      'ratingsCount': 110,
      'totalTravelers': 245,
      'itinerary': 'Day 1: Solang Valley, Day 2: Rohtang Pass',
      'languages': ['Hindi', 'English'],
      'price': '₹1899/day',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    // Determine crossAxisCount based on screen width
    final int crossAxisCount = screenWidth < 600 ? 2 : 3;
    // Calculate childAspectRatio dynamically based on screen width
    final double childAspectRatio = screenWidth < 600 ? 0.65 : 0.75;

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Experts'),
        backgroundColor: AppColors.appbar,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
        itemCount: _experts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: screenWidth * 0.04,
          crossAxisSpacing: screenWidth * 0.04,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          final expert = _experts[index];

          return GestureDetector(
            onTap: () {
              Get.to(() => ExpertProfilePage(
                expertImage: expert['image'],
                expertName: expert['name'],
                expertTitle: expert['title'],
                locationExpertise: expert['locationExpertise'],
                rating: expert['rating'],
                ratingsCount: expert['ratingsCount'],
                totalTravelers: expert['totalTravelers'],
                itinerary: expert['itinerary'],
                languages: List<String>.from(expert['languages']),
              ));
            },
            child: Card(
              color: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.buttonBg, width: 0.1),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03), // 3% of screen width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.08, // 8% of screen width
                      backgroundImage: NetworkImage(expert['image']),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      expert['name'],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.035, // Responsive font size
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      expert['title'],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.03,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      expert['locationExpertise'],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.028,
                        color: Colors.white54,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${expert['rating']}',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.028,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '(${expert['ratingsCount']})',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.028,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      expert['languages'].join(', '),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.028,
                        color: Colors.white54,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.015),
                    Text(
                      expert['price'] ?? '₹0/day',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.032,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}