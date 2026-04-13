import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/utils/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<dynamic> _friends = [];
  List<dynamic> _incomingRequests = [];
  List<dynamic> _outgoingRequests = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    _setLoading(true);
    try {
      await Future.wait([
        _fetchFriends(),
        _fetchIncomingRequests(),
        _fetchOutgoingRequests(),
      ]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchFriends() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    try {
      final response = await _apiService.listFriends();
      if (response.success && response.data != null) {
        setState(() {
          _friends = response.data!;
        });
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _fetchIncomingRequests() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    try {
      final response = await _apiService.listIncomingRequests();
      if (response.success && response.data != null) {
        setState(() {
          _incomingRequests = response.data!;
        });
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _fetchOutgoingRequests() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    try {
      final response = await _apiService.listOutgoingRequests();
      if (response.success && response.data != null) {
        setState(() {
          _outgoingRequests = response.data!;
        });
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _searchFriends(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await _apiService.searchFriends(query);
      if (response.success && response.data != null) {
        setState(() {
          _searchResults = response.data!;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _setError(e.toString());
    }
  }

  Future<void> _sendFriendRequest(int userId) async {
    try {
      final response = await _apiService.sendFriendRequest(userId);
      if (response.success) {
        _showSnackBar('Friend request sent!', Colors.green);
        _searchController.clear();
        setState(() {
          _searchResults = [];
        });
        _fetchOutgoingRequests();
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    try {
      final response = await _apiService.acceptFriendRequest(requestId);
      if (response.success) {
        _showSnackBar('Friend request accepted!', Colors.green);
        _fetchAll();
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      final response = await _apiService.rejectFriendRequest(requestId);
      if (response.success) {
        _showSnackBar('Friend request rejected', Colors.orange);
        _fetchIncomingRequests();
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _removeFriend(int friendUserId) async {
    try {
      final response = await _apiService.removeFriend(friendUserId);
      if (response.success) {
        _showSnackBar('Friend removed', Colors.orange);
        _fetchFriends();
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
      if (value) _error = null;
    });
  }

  void _setError(String error) {
    setState(() {
      _error = error;
      _isLoading = false;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return _buildLoginPrompt();
    }

    return Scaffold(
      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              title: const Text(
                'Friends',
                style: TextStyle(
                  color: AppConstants.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppConstants.primaryColor,
                unselectedLabelColor: AppConstants.secondaryColor,
                indicatorColor: AppConstants.primaryColor,
                tabs: [
                  Tab(text: 'Friends (${_friends.length})'),
                  Tab(text: 'Incoming (${_incomingRequests.length})'),
                  Tab(text: 'Outgoing (${_outgoingRequests.length})'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFriendsTab(),
            _buildIncomingTab(),
            _buildOutgoingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: AppConstants.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please login to view and manage your friends.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _searchResults.isNotEmpty
              ? _buildSearchResults()
              : _friends.isEmpty
                  ? _buildEmptyState('No friends yet', 'Search to add friends')
                  : _buildFriendsList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _searchFriends,
        decoration: InputDecoration(
          hintText: 'Search friends by name or email...',
          prefixIcon: const Icon(Icons.search, color: AppConstants.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppConstants.primaryColor.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(
          user: user,
          trailing: IconButton(
            icon: const Icon(Icons.person_add, color: AppConstants.primaryColor),
            onPressed: () => _sendFriendRequest(user['id']),
          ),
        );
      },
    );
  }

  Widget _buildFriendsList() {
    return RefreshIndicator(
      onRefresh: _fetchFriends,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return _buildUserTile(
            user: friend,
            trailing: IconButton(
              icon: const Icon(Icons.person_remove, color: Colors.red),
              onPressed: () => _confirmRemoveFriend(friend),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomingTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      );
    }

    if (_incomingRequests.isEmpty) {
      return _buildEmptyState('No incoming requests', 'Friend requests will appear here');
    }

    return RefreshIndicator(
      onRefresh: _fetchIncomingRequests,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _incomingRequests.length,
        itemBuilder: (context, index) {
          final request = _incomingRequests[index];
          return _buildRequestTile(
            request: request,
            showActions: true,
            onAccept: () => _acceptRequest(request['id']),
            onReject: () => _rejectRequest(request['id']),
          );
        },
      ),
    );
  }

  Widget _buildOutgoingTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      );
    }

    if (_outgoingRequests.isEmpty) {
      return _buildEmptyState('No outgoing requests', 'Sent requests will appear here');
    }

    return RefreshIndicator(
      onRefresh: _fetchOutgoingRequests,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _outgoingRequests.length,
        itemBuilder: (context, index) {
          final request = _outgoingRequests[index];
          return _buildRequestTile(
            request: request,
            showActions: false,
          );
        },
      ),
    );
  }

  Widget _buildUserTile({required dynamic user, required Widget trailing}) {
    final displayName = user['display_name'] ?? user['email'] ?? 'User';
    final photoUrl = user['photo_url'];
    final email = user['email'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          email,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.secondaryColor,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildRequestTile({
    required dynamic request,
    required bool showActions,
    VoidCallback? onAccept,
    VoidCallback? onReject,
  }) {
    final fromUser = request['from_user'] ?? request;
    final displayName = fromUser['display_name'] ?? fromUser['email'] ?? 'User';
    final photoUrl = fromUser['photo_url'];
    final email = fromUser['email'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          email,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.secondaryColor,
          ),
        ),
        trailing: showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: onAccept,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: onReject,
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppConstants.secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.secondaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveFriend(dynamic friend) {
    final displayName = friend['display_name'] ?? friend['email'] ?? 'this friend';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $displayName from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFriend(friend['id']);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
