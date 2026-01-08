import 'package:flutter/material.dart';
import '../account/login.dart';
import 'donation.dart';
import 'admin.dart';
import 'recepient.dart';
import 'volunteer.dart';
import 'seller.dart';

// --- Shared Constants ---
const Color primaryGreen = Color(0xFF4CAF50);
const Color darkGreen = Color(0xFF388E3C);
const Color deepBlue = Color(0xFF5C6BC0);

class FoodShareHomePage extends StatefulWidget {
  final String userName;
  final String userCategory;
  const FoodShareHomePage({
    super.key,
    required this.userName,
    required this.userCategory,
  });

  @override
  State<FoodShareHomePage> createState() => _FoodShareHomePageState();
}

class _FoodShareHomePageState extends State<FoodShareHomePage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      _buildMessagePage(),
      _buildNotificationPage(),
      _buildSettingPage(),
    ];
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(widget.userName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildWeatherCard(),
                const SizedBox(height: 20),
                _buildImpactCard(),
                const SizedBox(height: 30),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                _buildQuickActionsGrid(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagePage() {
    return const Center(
      child: Text('Message Page', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildNotificationPage() {
    return const Center(
      child: Text('Notification Page', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildSettingPage() {
    return const Center(
      child: Text('Setting Page', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String name) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '9:41 AM',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    'FoodShare',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '98%',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning, $name! 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Category: ${widget.userCategory}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) => PopupMenuButton<String>(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'profile') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Profile'),
                              content: Text('User: ${widget.userName}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else if (value == 'logout') {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Text('Profile View'),
                        ),
                        PopupMenuItem(value: 'logout', child: Text('Logout')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('47', 'ITEMS DONATED', Colors.white),
                  _buildStatItem('23', 'PEOPLE HELPED', Colors.white),
                  _buildStatItem('₹1,240', 'COMMUNITY SAVED', Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF81D4FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Dhaka, BD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '28°C',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Perfect weather for food deliveries!',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          const Text('☀️', style: TextStyle(fontSize: 60)),
        ],
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepBlue, Color(0xFF7986CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🌍 Your Community Impact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('156kg', 'FOOD SAVED', Colors.white),
              _buildStatItem('89', 'MEALS PROVIDED', Colors.white),
              _buildStatItem('45', 'CO₂ REDUCED', Colors.white),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          const Text(
            'Amazing work! You\'ve made a real difference in reducing food waste and helping families in need.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    List<Map<String, dynamic>> actions = [];

    if (widget.userCategory == 'Admin') {
      actions = [
        {
          'icon': Icons.admin_panel_settings,
          'title': 'Manage Users',
          'subtitle': 'Admin controls',
          'iconColor': Colors.red,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          },
        },
        {
          'icon': Icons.report,
          'title': 'View Reports',
          'subtitle': 'Analytics',
          'iconColor': Colors.blue,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          },
        },
        {
          'icon': Icons.settings,
          'title': 'Settings',
          'subtitle': 'App config',
          'iconColor': Colors.grey,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          },
        },
        {
          'icon': Icons.help,
          'title': 'Help',
          'subtitle': 'Support',
          'iconColor': Colors.green,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          },
        },
      ];
    } else if (widget.userCategory == 'Donor') {
      actions = [
        {
          'icon': Icons.card_giftcard,
          'title': 'Donate Food',
          'subtitle': 'Share surplus items',
          'iconColor': primaryGreen,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DonationPage()),
            );
          },
        },
        {
          'icon': Icons.history,
          'title': 'My Donations',
          'subtitle': 'View history',
          'iconColor': Colors.orange,
          'onTap': () {},
        },
        {
          'icon': Icons.shopping_bag_outlined,
          'title': 'Browse Food',
          'subtitle': 'Find available food',
          'iconColor': Colors.deepPurple,
          'onTap': () {},
        },
        {
          'icon': Icons.people,
          'title': 'Volunteers',
          'subtitle': 'Find volunteers',
          'iconColor': const Color.fromARGB(255, 235, 136, 7),
          'onTap': () {},
        },
      ];
    } else if (widget.userCategory == 'Recipient') {
      actions = [
        {
          'icon': Icons.food_bank,
          'title': 'Request Food',
          'subtitle': 'Find available food',
          'iconColor': Colors.deepPurple,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecepientPage()),
            );
          },
        },
        {
          'icon': Icons.shopping_bag_outlined,
          'title': 'Browse Food',
          'subtitle': 'Find nearby deals',
          'iconColor': Colors.deepPurple,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecepientPage()),
            );
          },
        },
        {
          'icon': Icons.location_on,
          'title': 'Nearby',
          'subtitle': 'Locations',
          'iconColor': Colors.red,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecepientPage()),
            );
          },
        },
        {
          'icon': Icons.star,
          'title': 'Favorites',
          'subtitle': 'Saved items',
          'iconColor': Colors.yellow,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecepientPage()),
            );
          },
        },
      ];
    } else if (widget.userCategory == 'Volunteer') {
      actions = [
        {
          'icon': Icons.volunteer_activism,
          'title': 'Manage Donations',
          'subtitle': 'Help donors',
          'iconColor': primaryGreen,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VolunteerPage()),
            );
          },
        },
        {
          'icon': Icons.people,
          'title': 'Coordinate Recipients',
          'subtitle': 'Assist recipients',
          'iconColor': Colors.blue,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VolunteerPage()),
            );
          },
        },
        {
          'icon': Icons.report,
          'title': 'View Reports',
          'subtitle': 'Volunteering stats',
          'iconColor': Colors.orange,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VolunteerPage()),
            );
          },
        },
        {
          'icon': Icons.help,
          'title': 'Help Requests',
          'subtitle': 'Support needed',
          'iconColor': Colors.purple,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VolunteerPage()),
            );
          },
        },
      ];
    } else if (widget.userCategory == 'Seller') {
      actions = [
        {
          'icon': Icons.list,
          'title': 'Product List',
          'subtitle': 'View all products',
          'iconColor': Colors.orange,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SellerPage()),
            );
          },
        },
        {
          'icon': Icons.add_circle,
          'title': 'Add Product',
          'subtitle': 'Add new product',
          'iconColor': Colors.green,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SellerPage()),
            );
          },
        },
        {
          'icon': Icons.edit,
          'title': 'Edit Products',
          'subtitle': 'Modify products',
          'iconColor': Colors.blue,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SellerPage()),
            );
          },
        },
        {
          'icon': Icons.bar_chart,
          'title': 'View Sales',
          'subtitle': 'Sales reports',
          'iconColor': Colors.purple,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SellerPage()),
            );
          },
        },
      ];
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: actions
          .map(
            (action) => _buildActionButton(
              icon: action['icon'],
              title: action['title'],
              subtitle: action['subtitle'],
              iconColor: action['iconColor'],
              onTap: action['onTap'],
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 238, 238),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color.fromARGB(255, 133, 240, 136),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blue.shade300,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}
