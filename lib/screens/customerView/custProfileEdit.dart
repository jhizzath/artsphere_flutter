import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artsphere/model/custPorfileModel.dart';
import 'package:artsphere/controller/customer/CustomerProfileController.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final controller = Get.find<CustomerProfileController>();
  final _formKey = GlobalKey<FormState>();
  Worker? _profileWorker; // To store the ever() worker
  bool _isDisposed = false;

  late final TextEditingController usernameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController houseCtrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController districtCtrl;
  late final TextEditingController stateCtrl;
  late final TextEditingController postalCtrl;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with empty values first
    usernameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    houseCtrl = TextEditingController();
    cityCtrl = TextEditingController();
    districtCtrl = TextEditingController();
    stateCtrl = TextEditingController();
    postalCtrl = TextEditingController();

     

    // Load initial data
    if (controller.profile.value != null) {
      _loadProfileData(controller.profile.value!);
    } else {
      controller.fetchProfile();
    }
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the worker to listen for profile changes
    _profileWorker = ever<CustomerProfile?>(
      controller.profile,
      (profile) {
        if (profile != null && !_isDisposed) {
          _loadProfileData(profile);
        }
      }
    );
  }

  void _loadProfileData(CustomerProfile profile) {
    if (!mounted) return; // Check if widget is still mounted
    
    setState(() {
      usernameCtrl.text = profile.username;
      emailCtrl.text = profile.email;
      phoneCtrl.text = profile.phoneNo ?? '';
      
      if (profile.addresses.isNotEmpty) {
        final address = profile.addresses[0];
        houseCtrl.text = address.houseAddress;
        cityCtrl.text = address.city;
        districtCtrl.text = address.district;
        stateCtrl.text = address.state;
        postalCtrl.text = address.postalCode;
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedAddress = Address(
        houseAddress: houseCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        district: districtCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        postalCode: postalCtrl.text.trim(),
      );

      final updated = CustomerProfile(
        username: usernameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phoneNo: phoneCtrl.text.trim(),
        profilePicture: controller.profile.value?.profilePicture,
        addresses: [updatedAddress],
      );
      
      controller.updateProfile(updated);
      Get.back();
    }
  }

  @override
  void dispose() {

    _isDisposed = true;
    // Remove the listener
    _profileWorker?.dispose();
    
    usernameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    houseCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    postalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: houseCtrl,
                  decoration: InputDecoration(labelText: 'House Address'),
                ),
                TextFormField(
                  controller: cityCtrl,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                TextFormField(
                  controller: districtCtrl,
                  decoration: InputDecoration(labelText: 'District'),
                ),
                TextFormField(
                  controller: stateCtrl,
                  decoration: InputDecoration(labelText: 'State'),
                ),
                TextFormField(
                  controller: postalCtrl,
                  decoration: InputDecoration(labelText: 'Postal Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}