import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/buddy_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../core/utiles/match_score_helper.dart';
import 'filter_bottom_sheet.dart';
import 'buddy_card.dart';

class BuddySearchScreen extends StatefulWidget {
  const BuddySearchScreen({super.key});

  @override
  State<BuddySearchScreen> createState() => _BuddySearchScreenState();
}

class _BuddySearchScreenState extends State<BuddySearchScreen> {
  String? _selectedFaculty;
  String? _selectedHostel;
  String? _selectedAvailability;

  @override
  void initState() {
    super.initState();
    _loadBuddies();
  }

  void _loadBuddies() {
    final currentUser =
        context.read<AuthProvider>().currentUserModel;
    if (currentUser == null) return;
    context.read<BuddyProvider>().searchBuddies(
          currentUserId: currentUser.uid,
          faculty: _selectedFaculty,
          hostel: _selectedHostel,
          availability: _selectedAvailability,
        );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterBottomSheet(
        selectedFaculty: _selectedFaculty,
        selectedHostel: _selectedHostel,
        selectedAvailability: _selectedAvailability,
        onApply: (faculty, hostel, availability) {
          setState(() {
            _selectedFaculty = faculty;
            _selectedHostel = hostel;
            _selectedAvailability = availability;
          });
          _loadBuddies();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUserModel;
    final buddyProvider = context.watch<BuddyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Buddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: buddyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : buddyProvider.buddies.isEmpty
              ? const Center(child: Text('No buddies found. Try adjusting filters.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: buddyProvider.buddies.length,
                  itemBuilder: (context, index) {
                    final buddy = buddyProvider.buddies[index];
                    final score = currentUser != null
                        ? MatchScoreHelper.calculate(currentUser, buddy)
                        : 0;
                    return BuddyCard(
                      buddy: buddy,
                      matchScore: score,
                      onRequest: () => _sendRequest(buddy, score),
                    );
                  },
                ),
    );
  }

  void _sendRequest(UserModel buddy, int score) async {
    final currentUser = context.read<AuthProvider>().currentUserModel;
    if (currentUser == null) return;
    await context.read<BuddyProvider>().sendRequest(
          fromUserId: currentUser.uid,
          toUserId: buddy.uid,
          matchScore: score,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Buddy request sent to ${buddy.name}!')),
    );
  }
}