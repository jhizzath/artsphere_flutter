import 'package:artsphere/controller/artist/profileController.dart';
import 'package:artsphere/screens/artistView/editProfile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ArtistProfileController _profileController = Get.put(ArtistProfileController());

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null) {
      _profileController.fetchArtistProfile(username);
    } else {
      debugPrint("Username not found in SharedPreferences");
    }
  }

  Widget _buildAvatarImage(dynamic profile) {
    if (profile.artistProfile?.profilePicture != null) {
      return CachedNetworkImage(
        imageUrl: profile.artistProfile!.profilePicture!,
        placeholder: (context, url) => _buildPlaceholderAvatar(),
        errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
        fit: BoxFit.cover,
        width: 110,
        height: 110,
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        image: const DecorationImage(
          image: AssetImage('assets/default_avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = _profileController.artistProfile.value;
        if (profile == null) {
          return const Center(child: Text("Profile not found"));
        }

        return SingleChildScrollView(
          child: Container(
            color: const Color(0xFFF5F7FA),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[200],
                            child: ClipOval(
                              child: _buildAvatarImage(profile),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile.artistProfile?.name ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Chip(
                            label: Text(
                              profile.artistProfile?.profession ?? 'No Profession',
                            ),
                            avatar: const Icon(Icons.palette, color: Colors.white, size: 18),
                            backgroundColor: const Color(0xFF607D8B),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Profile Info Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.person, "Username", profile.username),
                          const Divider(),
                          _buildInfoTile(Icons.email, "Email", profile.email),
                          const Divider(),
                          _buildInfoTile(Icons.phone, "Phone No", profile.phoneNo),
                          const Divider(),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Art Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                _buildCategoryChip(profile.artistProfile!.category.name),
                              ],
                            ),
                          ),
                          const Divider(),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Art Subcategories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: profile.artistProfile!.subcategories
                                  .map((subcat) => _buildCategoryChip(subcat.name))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => EditProfilePage(category: profile.artistProfile!.category.id));
                        },
                        icon: const Icon(Icons.edit, color: Colors.black87),
                        label: const Text("Edit Profile", style: TextStyle(color: Colors.black87)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 254, 254, 254),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey.shade700),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        value.isNotEmpty ? value : 'Not provided',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A4747),
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
