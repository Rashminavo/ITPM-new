class AppStrings {
  // App
  static const String appName = 'Peer Buddy';
  static const String appTagline = 'Connect. Learn. Grow.';

  // Auth
  static const String login = 'Log In';
  static const String register = 'Sign Up';
  static const String logout = 'Log Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";

  // Profile
  static const String faculty = 'Faculty';
  static const String hostel = 'Hostel';
  static const String bio = 'Bio';
  static const String skills = 'Skills';
  static const String availability = 'Availability';
  static const String saveProfile = 'Save Profile';

  // Buddy Search
  static const String findBuddy = 'Find a Buddy';
  static const String filters = 'Filters';
  static const String applyFilters = 'Apply Filters';
  static const String clearFilters = 'Clear Filters';
  static const String requestBuddy = 'Send Request';
  static const String matchScore = 'Match Score';
  static const String noBuddiesFound = 'No buddies found.\nTry adjusting your filters.';

  // Chat
  static const String typeMessage = 'Type a message...';
  static const String encryptedChat = '🔒 End-to-end encrypted';
  static const String scheduleMeetup = 'Schedule Meetup';
  static const String shareFile = 'Share File';

  // My Buddies
  static const String myBuddies = 'My Buddies';
  static const String activeBuddies = 'Active Buddies';
  static const String history = 'History';
  static const String leaveFeedback = 'Leave Feedback';
  static const String noBuddiesYet = 'No active buddies yet.\nStart by finding a buddy!';

  // Forum
  static const String communityForum = 'Community Forum';
  static const String postTip = 'Post Tip';
  static const String anonymous = 'Anonymous';
  static const String postAnonymously = 'Post Anonymously';
  static const String report = 'Report';
  static const String upvote = 'Upvote';
  static const String downvote = 'Downvote';

  // Meetup
  static const String meetupTitle = 'Meetup Title';
  static const String meetupLocation = 'Location';
  static const String scheduleMeetupBtn = 'Schedule Meetup';
  static const String pickTime = 'Pick a Time';

  // Feedback
  static const String rateBuddySession = 'Rate your Buddy Session';
  static const String submitFeedback = 'Submit Feedback';
  static const String leaveComment = 'Leave a comment (optional)';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
  static const String invalidEmail = 'Please enter a valid email.';
  static const String weakPassword = 'Password must be at least 6 characters.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String fieldRequired = 'This field is required.';

  // Faculties
  static const List<String> faculties = [
    'Engineering',
    'Medicine',
    'Science',
    'Arts',
    'Law',
    'Business',
    'Education',
    'IT',
    'Architecture',
    'Other',
  ];

  // Hostels
  static const List<String> hostels = [
    'Block A',
    'Block B',
    'Block C',
    'Block D',
    'Block E',
    'Off-campus',
    'Other',
  ];

  // Availability slots
  static const List<String> availabilitySlots = [
    'Mon Morning',
    'Mon Afternoon',
    'Mon Evening',
    'Tue Morning',
    'Tue Afternoon',
    'Tue Evening',
    'Wed Morning',
    'Wed Afternoon',
    'Wed Evening',
    'Thu Morning',
    'Thu Afternoon',
    'Thu Evening',
    'Fri Morning',
    'Fri Afternoon',
    'Fri Evening',
    'Sat Morning',
    'Sat Afternoon',
    'Sun Morning',
    'Sun Afternoon',
  ];
}