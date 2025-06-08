

import 'package:google_sign_in/google_sign_in.dart'; // Keep this if you plan to add Google Sign-In later
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Keep if you use the Gemini part
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Add Firebase imports (already present, good)
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart'; // Ensure this file is generated and imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure Firebase is initialized before runApp
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Optionally handle initialization errors, e.g., show an error screen
  }

  runApp(const FoodDonationApp());
}

// --- Global Theme Colors ---
const Color primaryColor = Color.fromARGB(255, 208, 67, 255); // Primary Accent
const Color secondaryColor =
    Color.fromARGB(255, 103, 227, 255); // Secondary Accent
const Color darkBackgroundColor = Color.fromARGB(255, 24, 18, 18);
const Color darkSurfaceColor = Color.fromARGB(255, 0, 0, 0); // Slightly lighter dark
const Color darkCardColor = Color.fromARGB(255, 75, 54, 108);
const Color darkOnSurfaceColor = Colors.white;
const Color darkOnSurfaceVariantColor = Colors.white70;

// --- Dummy User ID (REPLACED BY FIREBASE AUTH) ---
// const String currentUserId = 'user123'; // Remove or comment out

class FoodDonationApp extends StatelessWidget {
  const FoodDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DonationProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PlateMate',
        theme: ThemeData(
            useMaterial3: true, // Enable Material 3 features
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              secondary: secondaryColor,
              surface: darkSurfaceColor,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: darkOnSurfaceColor,
              error: Colors.redAccent,
              onError: Colors.white,
              surfaceContainerHighest:
                  darkCardColor, // Used for cards, containers
              onSurfaceVariant:
                  darkOnSurfaceVariantColor, // Text on cards/inputs
              outline: Colors.white30, // For borders
            ),
            scaffoldBackgroundColor: darkBackgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor:
                  darkSurfaceColor, // Slightly lighter than background
              elevation: 1, // Subtle shadow
              titleTextStyle: TextStyle(
                color: darkOnSurfaceColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: IconThemeData(color: darkOnSurfaceColor),
              centerTitle: true,
            ),
            cardTheme: CardTheme(
              color: darkCardColor,
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                color: darkOnSurfaceColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              titleLarge: TextStyle(
                color: darkOnSurfaceColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ), // Card titles, section headers
              bodyLarge: TextStyle(
                color: darkOnSurfaceColor,
                fontSize: 16,
              ), // Main text
              bodyMedium: TextStyle(
                color: darkOnSurfaceVariantColor,
                fontSize: 14,
              ), // Detail text, hint text
              labelLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ), // Button text
              labelMedium: TextStyle(
                  color: darkOnSurfaceVariantColor, fontSize: 12), // Input labels
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: darkSurfaceColor, // Input field background
              labelStyle: const TextStyle(color: darkOnSurfaceVariantColor),
              hintStyle: const TextStyle(color: darkOnSurfaceVariantColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 15.0,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white, // Text color
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 2,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              // Added TextButton theme
              style: TextButton.styleFrom(
                foregroundColor: primaryColor, // Use primary color for text buttons
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
            ),
            listTileTheme: const ListTileThemeData(
              // Added ListTile theme
              textColor: darkOnSurfaceColor,
              iconColor: darkOnSurfaceVariantColor,
              tileColor:
                  darkSurfaceColor, // Slightly lighter background for tiles
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            )),
        // Use a StreamBuilder to listen to authentication state changes
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show a loading indicator while checking the auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // If user data exists, they are logged in
            if (snapshot.hasData && snapshot.data != null) {
              print("User logged in: ${snapshot.data!.uid}");
              return const HomeScreen(); // Navigate to Home if logged in
            } else {
              // If no user data, they are logged out
              print("No user logged in.");
              return const LoginPage(); // Navigate to Login if logged out
            }
          },
        ),
      ),
    );
  }
}

// ---------------------------- LOGIN PAGE (MODIFIED FOR FIREBASE) ----------------------------

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _isSignUp = false; // State to toggle between Login and Sign Up mode

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   Future<void> _authenticate() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       if (_isSignUp) {
//         // Sign Up logic
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//         // If successful, Firebase auth state changes and StreamBuilder navigates
//          ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Account created successfully! Welcome.'),
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       } else {
//         // Login logic
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//         // If successful, Firebase auth state changes and StreamBuilder navigates
//          ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Logged in successfully!'),
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       if (_isSignUp) {
//         if (e.code == 'weak-password') {
//           errorMessage = 'The password provided is too weak.';
//         } else if (e.code == 'email-already-in-use') {
//           errorMessage = 'The account already exists for that email.';
//         } else {
//           errorMessage = 'Sign Up Failed: ${e.message}';
//         }
//       } else {
//         if (e.code == 'user-not-found') {
//           errorMessage = 'No user found for that email.';
//         } else if (e.code == 'wrong-password') {
//           errorMessage = 'Wrong password provided for that user.';
//         } else if (e.code == 'invalid-email') {
//            errorMessage = 'The email address is invalid.';
//         }
//          else {
//           errorMessage = 'Login Failed: ${e.message}';
//         }
//       }
//       _showError(errorMessage);
//       print("Firebase Auth Error: ${e.code} - ${e.message}");
//     } catch (e) {
//       _showError('An unexpected error occurred. Please try again.');
//       print("General Error during Auth: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.food_bank_rounded, // Example Logo
//                 size: 80,
//                 color: colorScheme.primary,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Welcome to PlateMate',
//                 style: textTheme.headlineSmall,
//                 textAlign: TextAlign.center,
//               ),
//                const SizedBox(height: 10),
//               Text(
//                 _isSignUp ? 'Create Your Account' : 'Login to Your Account',
//                  style: textTheme.titleLarge,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(
//                     Icons.email_outlined, // Changed to email icon
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                   labelText: 'Email', // Changed label to Email
//                 ),
//                 keyboardType: TextInputType.emailAddress, // Set keyboard type
//                  textCapitalization: TextCapitalization.none, // Don't capitalize email
//               ),
//               const SizedBox(height: 15),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(
//                     Icons.lock_outline,
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                   labelText: 'Password',
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 30),
//               _isLoading
//                   ? const CircularProgressIndicator() // Show loading indicator
//                   : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _authenticate, // Use the authenticate method
//                         child: Text(_isSignUp ? 'Sign Up' : 'Login'),
//                       ),
//                     ),
//               const SizedBox(height: 15),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _isSignUp = !_isSignUp; // Toggle mode
//                      // Clear fields when toggling, maybe not necessary but good practice
//                      _emailController.clear();
//                      _passwordController.clear();
//                   });
//                 },
//                 child: Text(_isSignUp
//                     ? 'Already have an account? Login'
//                     : 'Don\'t have an account? Sign Up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false; // State to toggle between Login and Sign Up mode

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return; // Prevent showing SnackBar if the widget is disposed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
     if (!mounted) return; // Prevent showing SnackBar if the widget is disposed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
  }


  Future<void> _authenticate() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
       _showError('Please enter email and password.');
       return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        // Sign Up logic
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // If successful, Firebase auth state changes and StreamBuilder navigates
         _showSuccess('Account created successfully! Welcome.');
      } else {
        // Login logic
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // If successful, Firebase auth state changes and StreamBuilder navigates
         _showSuccess('Logged in successfully!');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (_isSignUp) {
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else {
          errorMessage = 'Sign Up Failed: ${e.message}';
        }
      } else {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else if (e.code == 'invalid-email') {
           errorMessage = 'The email address is invalid.';
        }
         else {
          errorMessage = 'Login Failed: ${e.message}';
        }
      }
      _showError(errorMessage);
      print("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
      print("General Error during Auth: $e");
    } finally {
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Google Sign-In Method ---
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Check if the user canceled the sign-in process
      if (googleUser == null) {
        // User canceled the sign-in
        return; // Exit the function
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // If successful, Firebase auth state changes and StreamBuilder navigates
      _showSuccess('Signed in with Google successfully!');

    } on FirebaseAuthException catch (e) {
      print("Firebase Auth with Google Error: ${e.code} - ${e.message}");
      _showError('Google Sign-In Failed: ${e.message}');
    } catch (e) {
       print("General Error during Google Sign-In: $e");
      _showError('An unexpected error occurred during Google Sign-In.');
    } finally {
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // --- End Google Sign-In Method ---


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.food_bank_rounded, // Example Logo
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to PlateMate',
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
               const SizedBox(height: 10),
              Text(
                _isSignUp ? 'Create Your Account' : 'Login to Your Account',
                 style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined, // Changed to email icon
                    color: colorScheme.onSurfaceVariant,
                  ),
                  labelText: 'Email', // Changed label to Email
                ),
                keyboardType: TextInputType.emailAddress, // Set keyboard type
                 textCapitalization: TextCapitalization.none, // Don't capitalize email
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator() // Show loading indicator for any auth method
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _authenticate, // Disable button while loading
                        child: Text(_isSignUp ? 'Sign Up' : 'Login'),
                      ),
                    ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _isLoading ? null : () { // Disable button while loading
                  setState(() {
                    _isSignUp = !_isSignUp; // Toggle mode
                     // Clear fields when toggling, maybe not necessary but good practice
                     _emailController.clear();
                     _passwordController.clear();
                  });
                },
                child: Text(_isSignUp
                    ? 'Already have an account? Login'
                    : 'Don\'t have an account? Sign Up'),
              ),

              // --- Add Google Sign-In Button ---
              const SizedBox(height: 30), // Spacing
              Text('OR', style: textTheme.bodyMedium), // Optional separator
              const SizedBox(height: 20),
               _isLoading
                  ? const SizedBox.shrink() // Hide Google button while loading
                  : SizedBox(
                      width: double.infinity, // Make button wide
                      child: OutlinedButton.icon( // Using OutlinedButton.icon for a distinct look
                        icon: Image.asset( // Use a Google icon image
                          'assets/google_logo.webp', // Make sure you have a google_logo.png in your assets folder
                          height: 24.0,
                        ),
                        label: const Text('Sign In with Google'),
                        onPressed: _signInWithGoogle, // Call the Google sign-in method
                        style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 12),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                           side: BorderSide(color: colorScheme.outline), // Border color
                        ),
                      ),
                    ),
               // --- End Google Sign-In Button ---
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- HOME SCREEN (Uses Firebase User) ----------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donationProvider = Provider.of<DonationProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    // Get the current logged-in user's UID
    // This will be null if somehow reached without login (should be prevented by StreamBuilder)
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      // Should ideally not happen with StreamBuilder, but as a fallback
      return const Scaffold(
        body: Center(
          child: Text("User not logged in. Please restart app."),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('PlateMate Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none), // Notification Icon
            tooltip: 'Notifications',
            onPressed: () {
              // TODO: Handle notifications action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications not implemented yet.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined), // Profile Icon
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProfileScreen()),
              );
            },
          ),
          // Only show Gemini chat if user is logged in (as it might interact with user data later)
           if (currentUserId != null) // Already checked above, but good practice
             IconButton(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const GeminiScreen()),
                 );
               },
               icon: const Icon(Icons.chat_outlined), // Using outlined version for consistency
               tooltip: 'Chat with AI Assistant',
             ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: donationProvider.donations.isEmpty
                ? Center(
                    child: Column(
                      // Empty State
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_food_outlined,
                          size: 60,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No donations available yet.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Check back later or add a donation!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          0.75, // Adjust aspect ratio for better fit
                    ),
                    itemCount: donationProvider.donations.length,
                    itemBuilder: (context, index) {
                      final donation = donationProvider.donations[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonationDetailsScreen(
                                donation: donation,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          // Using CardTheme defined globally
                          clipBehavior: Clip
                              .antiAlias, // Ensures image respects card rounding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3, // Give more space to image
                                child: Hero(
                                  // Add Hero animation for image transition
                                  // Using donation.id for a more stable tag
                                  tag: 'donation_image_${donation.id}',
                                  child: donation.image != null
                                      ? Image.file(
                                          File(donation.image!),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              _buildPlaceholderImage(context),
                                        )
                                      : _buildNetworkImage(donation.foodName),
                                ),
                              ),
                              Expanded(
                                flex: 2, // Give less space to text details
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly, // Distribute space
                                    children: [
                                      Text(
                                        donation.foodName,
                                        style: textTheme.titleLarge?.copyWith(
                                          fontSize: 16,
                                        ), // Slightly smaller title
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Qty: ${donation.quantity}",
                                        style: textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Expires: ${donation.expiryDate}",
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 12,
                                        ), // Even smaller detail
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            // Add padding around the request button
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 15,
              top: 5,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.request_page_outlined),
                label: const Text("Request Food"),
                onPressed: () {
                   if (currentUserId == null) {
                       _showLoginRequiredMessage(context);
                       return;
                   }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestFoodScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondary, // Use secondary color
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Use extended FAB
        onPressed: () {
            if (currentUserId == null) {
                _showLoginRequiredMessage(context);
                return;
            }
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DonateFoodScreen()),
              );
        },
        icon: const Icon(Icons.add),
        label: const Text("Donate"),
      ),
    );
  }

    void _showLoginRequiredMessage(BuildContext context) {
         ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please log in to donate or request food.'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
    }


  Widget _buildNetworkImage(String foodName) {
    return FutureBuilder<String>(
      future: getUnsplashImage(foodName), // Fetch the image URL
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          ); // Show loading indicator
        } else if (snapshot.hasError || !snapshot.hasData) {
          return _buildPlaceholderImage(context); // Show placeholder on error or no data
        } else {
          return CachedNetworkImage( // Use the fetched image
            imageUrl: snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            errorWidget: (context, url, error) => _buildPlaceholderImage(context),
            placeholder: (context, url) => Center( // Add a subtle placeholder while loading network image
                child: Icon(
                  Icons.fastfood_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  size: 30,
                )),
          );
        }
      },
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.fastfood_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          size: 40,
        ),
      ),
    );
  }
}

// ---------------------------- DONATION DETAILS SCREEN (Uses Firebase User) ----------------------------

class DonationDetailsScreen extends StatelessWidget {
  final FoodDonation donation;

  const DonationDetailsScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

    // Find the index to create a unique Hero tag if needed,
    // but using donation.id directly in the tag is more robust.
    // int index = Provider.of<DonationProvider>(context, listen: false).donations.indexOf(donation); // Not strictly needed for tag
    // String heroTag = 'donation_image_${donation.id}_$index'; // Using ID is sufficient

    return Scaffold(
      appBar: AppBar(title: Text(donation.foodName)),
      body: SingleChildScrollView(
        // Allow scrolling for long descriptions
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                // Match Hero tag from list (using donation.id)
                tag: 'donation_image_${donation.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: donation.image != null
                      ? Image.file(
                          File(donation.image!),
                          width: MediaQuery.of(context).size.width *
                              0.7, // Responsive width
                          height: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDetailPlaceholderImage(context, context.size!.width * 0.7),
                        )
                      : FutureBuilder<String>( // Use FutureBuilder here as well
                          future: getUnsplashImage(donation.foodName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildDetailPlaceholderImage(context, context.size!.width * 0.7, loading: true);
                            } else if (snapshot.hasError || !snapshot.hasData) {
                               return _buildDetailPlaceholderImage(context, context.size!.width * 0.7);
                            } else {
                              return CachedNetworkImage(
                                imageUrl: snapshot.data!,
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _buildDetailPlaceholderImage(context, context.size!.width * 0.7, loading: true),
                                errorWidget: (context, url, error) => _buildDetailPlaceholderImage(context, context.size!.width * 0.7),
                              );
                            }
                          }),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildDetailRow(
              context,
              Icons.fastfood_outlined,
              'Food',
              donation.foodName,
              isTitle: true,
            ),
             _buildDetailRow( // Added Donor Info
              context,
              Icons.person_outline,
              'Donor',
              donation.userId == currentUserId ? 'You' : 'Community Member', // Show 'You' if it's the current user's donation
            ),
            _buildDetailRow(
              context,
              Icons.category_outlined,
              'Category',
              donation.category.displayName, // Use displayName
            ),
            _buildDetailRow(
              context,
              Icons.scale_outlined,
              'Quantity',
              donation.quantity,
            ),
            _buildDetailRow(
              context,
              Icons.date_range_outlined,
              'Expires On',
              donation.expiryDate,
            ),
            _buildDetailRow(
              context,
              Icons.access_time_outlined,
              'Best Before',
              donation.bestBeforeTime,
            ),
            _buildDetailRow(
              context,
              Icons.description_outlined,
              'Description',
              donation.description,
            ),
            const SizedBox(height: 30),
             // Show chat/pickup options ONLY if a user is logged in AND it's NOT their own donation
            if (currentUserId != null && donation.userId != currentUserId) ...[
             SizedBox(
                // Wrap buttons in SizedBox for width control
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat with Donor'),
                  onPressed: () {
                     // Check if logged in (already checked above, but extra safety)
                     if (currentUserId == null) {
                         _showLoginRequiredMessage(context);
                         return;
                     }
                    // Use donation ID to identify the chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: donation.id, title: 'Chat about ${donation.foodName}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Arrange Pickup'),
                  onPressed: () {
                     // Check if logged in
                     if (currentUserId == null) {
                         _showLoginRequiredMessage(context);
                         return;
                     }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PickupArrangementScreen(donation: donation),
                      ),
                    );
                  },
                ),
              ),
               const SizedBox(height: 15),
            ],
             // Option to delete *your* donation (only if logged in and it's your donation)
            if (currentUserId != null && donation.userId == currentUserId)
              SizedBox(
                width: double.infinity,
                 child: ElevatedButton.icon(
                   icon: const Icon(Icons.delete_outline),
                   label: const Text('Delete This Donation'),
                   onPressed: () {
                      // Check if logged in (already checked above)
                     if (currentUserId == null) {
                         _showLoginRequiredMessage(context);
                         return;
                     }
                     _showDeleteConfirmationDialog(context, donation);
                   },
                   style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Indicate destructive action
                   ),
                 ),
              ),

          ],
        ),
      ),
    );
  }

     void _showLoginRequiredMessage(BuildContext context) {
         ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please log in to interact with donations.'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
    }


  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isTitle = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isTitle)
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant
                    ),
                  ),
                Text(
                  value,
                  style: isTitle
                      ? textTheme.headlineSmall?.copyWith(fontSize: 22)
                      : textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildDetailPlaceholderImage(BuildContext context, double size, {bool loading = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: loading
            ? CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)
            : Icon(
                Icons.broken_image_outlined,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.5),
                size: 50,
              ),
      ),
    );
  }

   void _showDeleteConfirmationDialog(BuildContext context, FoodDonation donation) {
     final theme = Theme.of(context);
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           backgroundColor: theme.colorScheme.surface,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(15),
           ),
           title: Text(
             'Delete Donation?',
             style: theme.textTheme.titleLarge,
           ),
           content: Text(
             'Are you sure you want to delete the donation "${donation.foodName}"? This action cannot be undone.',
             style: theme.textTheme.bodyMedium,
           ),
           actions: [
             TextButton(
               child: Text(
                 'Cancel',
                 style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
               ),
               onPressed: () {
                 Navigator.of(context).pop();
               },
             ),
             ElevatedButton(
               onPressed: () {
                 Provider.of<DonationProvider>(context, listen: false)
                     .removeDonation(donation.id);
                 Navigator.of(context).pop(); // Close dialog
                 Navigator.of(context).pop(); // Go back from details screen
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('${donation.foodName} deleted.'),
                     backgroundColor: Colors.redAccent,
                     behavior: SnackBarBehavior.floating,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10),
                     ),
                   ),
                 );
               },
               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
               child: const Text('Delete'),
             ),
           ],
         );
       },
     );
   }
}

// ---------------------------- CHAT SCREEN (Uses Firebase User) ----------------------------

class ChatScreen extends StatefulWidget {
  final String chatId; // Unique ID for this chat (e.g., donation ID)
  final String title; // Title for the app bar

  const ChatScreen({super.key, required this.chatId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatProvider _chatProvider; // Hold provider instance
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
     if (_currentUserId == null) {
        // If user is somehow not logged in, navigate back or show error
        // This case should ideally be handled by the StreamBuilder on the main page
        print("ChatScreen reached without logged-in user.");
        // Future.microtask(() => Navigator.pop(context)); // Example: go back immediately
        return;
     }
    // Get the provider instance
    _chatProvider = Provider.of<ChatProvider>(context);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
     if (_currentUserId == null) {
        print("Attempted to send message while logged out.");
        // Handle logged out state if necessary, though StreamBuilder should prevent this.
        return;
    }

    if (messageText.isNotEmpty) {
      final newMessage = ChatMessage(
        text: messageText,
        timestamp: DateTime.now(),
        userId: _currentUserId!, // Assign the actual user ID
      );

      // Add message using ChatProvider
      _chatProvider.addMessage(widget.chatId, newMessage);

      _messageController.clear();

      // Simulate a reply after a short delay (optional)
       // In a real app, this would be handled by the other user or a backend service
       Future.delayed(const Duration(seconds: 1), () {
          final dummyOtherUserId = _currentUserId == 'userVeg001' ? 'otherUser123' : 'userVeg001'; // Example dummy ID
         final replyMessage = ChatMessage(
           text: "Thanks for your message! I'll get back to you shortly.", // Example AI or automated reply
           timestamp: DateTime.now(),
           userId: dummyOtherUserId, // Assign a dummy other user ID
         );
         _chatProvider.addMessage(widget.chatId, replyMessage);
       });
    }
  }

  @override
  Widget build(BuildContext context) {
     // If not logged in, show an error or loading (though StreamBuilder prevents this screen)
     if (_currentUserId == null) {
       return Scaffold(appBar: AppBar(title: Text(widget.title)), body: const Center(child: Text("Please log in to chat.")));
     }

    // Get messages for this specific chat
    final messages = _chatProvider.getMessages(widget.chatId);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Start the conversation!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    reverse: true, // Show latest messages at the bottom
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      // Access messages in reverse for display
                      final message = messages[messages.length - 1 - index];
                       // Determine if the message is from the current user
                       // This logic is now in the ChatBubble widget itself
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color:
            colorScheme.surface, // Use surface color for input area background
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                fillColor: colorScheme
                    .surface, // Slightly different background for input field itself
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(), // Send on keyboard done action
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send_rounded),
            color: colorScheme.primary,
            tooltip: 'Send Message',
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// --- Chat Message Model (Updated with userId) ---
class ChatMessage {
  final String text;
  // final bool isMe; // We can now derive this from userId
  final DateTime timestamp;
  final String userId; // Store the ID of the user who sent the message

  ChatMessage({
    required this.text,
    // required this.isMe, // Removed
    required this.timestamp,
    required this.userId, // Added
  });
}

// --- Chat Bubble Widget (Updated to use userId) ---
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine if the message is from the current user
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isMe = currentUserId != null && message.userId == currentUserId;

    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor =
        isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ), // Limit bubble width
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        child: Column(
          // Add timestamp below message
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'hh:mm a',
              ).format(message.timestamp), // Format timestamp
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------- PICKUP ARRANGEMENT SCREEN ----------------------------

class PickupArrangementScreen extends StatefulWidget {
  final FoodDonation donation;

  const PickupArrangementScreen({super.key, required this.donation});

  @override
  State<PickupArrangementScreen> createState() =>
      _PickupArrangementScreenState();
}

class _PickupArrangementScreenState extends State<PickupArrangementScreen> {
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  TimeOfDay? _selectedTime;
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController =
      TextEditingController(); // Optional notes

   final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID


  @override
  void dispose() {
    _timeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

   @override
   void initState() {
     super.initState();
      // Check if user is logged in when the screen is initialized
      if (_currentUserId == null) {
         // If user is not logged in, show a message and navigate back
         Future.microtask(() { // Use microtask to avoid build errors
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Please log in to arrange pickup.'),
               backgroundColor: Theme.of(context).colorScheme.error,
               behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
             ),
           );
           Navigator.pop(context); // Go back to the previous screen (Donation Details)
         });
      }
   }


  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select Pickup Time', // More descriptive help text
      builder: (context, child) {
        // Apply theme to picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context)
                  .colorScheme
                  .primary, // Use your primary color
              onSurface: Theme.of(context).colorScheme.onSurface, // Ensure text color is visible
              surface: Theme.of(context).colorScheme.surfaceContainerHighest, // Background of picker
            ),
            textButtonTheme: TextButtonThemeData( // Style the OK/Cancel buttons
               style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary, // Use primary color for buttons
               ),
            )
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = _selectedTime!.format(context);
      });
    }
  }

  void _confirmArrangement() {
     if (_currentUserId == null) {
         // Should have been caught by initState, but double check
         print("Attempted to confirm pickup while logged out.");
         return;
      }
    if (_formKey.currentState!.validate()) {
      // Form is valid, show confirmation dialog
      _showConfirmationDialog(context);
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final pickupTime = _selectedTime?.format(context) ?? "Not selected";
    final pickupLocation = _locationController.text.trim();
    final notes = _notesController.text.trim();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Confirm Pickup Details',
            style: theme.textTheme.titleLarge,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Food: ${widget.donation.foodName}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text('Time: $pickupTime', style: theme.textTheme.bodyMedium),
              Text(
                'Location: $pickupLocation',
                style: theme.textTheme.bodyMedium,
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: $notes', style: theme.textTheme.bodyMedium),
              ],
               const SizedBox(height: 12),
                Text(
                  'A message will be sent to the donor.',
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              // Use ElevatedButton for confirmation
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // TODO: Implement actual confirmation logic (send notification, update DB)
                // You could use the ChatProvider here to send a message to the donor's chat related to this donation.
                 final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                 final arrangementMessage = ChatMessage(
                    text: "Pickup arranged for ${widget.donation.foodName} at $_timeController. Location: $_locationController. Notes: ${notes.isNotEmpty ? notes : 'None'}.",
                    timestamp: DateTime.now(),
                    userId: _currentUserId!, // The requester's user ID
                 );
                 // Use the donation.id as the chatId for this conversation
                 chatProvider.addMessage(widget.donation.id, arrangementMessage);


                print(
                  'Pickup Confirmed by User $_currentUserId for Donation ${widget.donation.id}: Time: $pickupTime, Location: $pickupLocation, Notes: $notes',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Pickup arrangement confirmed! Donor notified.',
                    ),
                    backgroundColor: theme.colorScheme
                        .primary, // Use primary color for success
                    behavior: SnackBarBehavior.floating, // Modern look
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                // Optionally navigate back or clear fields
                Navigator.pop(
                  context,
                ); // Go back from pickup arrangement screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

     // Show loading or error if user is null initially
     if (_currentUserId == null) {
         return Scaffold(appBar: AppBar(title: Text('Arrange Pickup')), body: const Center(child: CircularProgressIndicator()));
     }


    return Scaffold(
      appBar: AppBar(title: const Text('Arrange Pickup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          // Wrap in Form
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Arranging pickup for:', style: textTheme.bodyMedium),
              Text(
                widget.donation.foodName,
                style: textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Preferred Pickup Time *',
                  prefixIcon: Icon(
                    Icons.access_time_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                readOnly: true,
                onTap: () => _selectTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a pickup time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location Address *',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the pickup location';
                  }
                  return null;
                },
                // No need for onChanged if only used for validation on submit
              ),
              const SizedBox(height: 15),
              TextFormField(
                // Optional Notes field
                controller: _notesController,
                decoration: InputDecoration(
                  labelText:
                      'Optional Notes (e.g., contact info, instructions)',
                  prefixIcon: Icon(
                    Icons.note_alt_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmArrangement,
                  child: const Text('Confirm Pickup Arrangement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- DONATION PROVIDER (Dummy Data Adjusted) ----------------------------

// Enum for food categories
enum FoodCategory {
  veg("Vegetarian"),
  nonVeg("Non-Vegetarian"),
  vegan("Vegan"),
  other("Other"); // Added 'Other'

  final String displayName;
  const FoodCategory(this.displayName);
}

class FoodDonation {
  final String id; // Unique ID for each donation
  final String foodName;
  final String expiryDate; // Should ideally be DateTime
  final String? image; // Path to local image file or null for network image
  final String quantity; // e.g., "2 packs", "500g"
  final String description;
  final String bestBeforeTime; // Should ideally be TimeOfDay/DateTime
  final FoodCategory category;
  final String userId; // Added user ID

  FoodDonation({
    required this.foodName,
    required this.expiryDate,
    this.image,
    required this.quantity,
    required this.description,
    required this.bestBeforeTime,
    required this.category,
    required this.userId, // User ID is now required
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(); // Simple unique ID generation
}

class DonationProvider extends ChangeNotifier {
  // Add some initial dummy data for demonstration
  // Use placeholder UIDs like 'dummyUser1', 'dummyUser2'
  final List<FoodDonation> _donations = [
    // Dummy data for other users
    FoodDonation(
  foodName: "Paneer Butter Masala",
  expiryDate: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 2))),
  quantity: "Approx 800ml",
  description: "Rich paneer curry made with butter and tomato gravy.",
  bestBeforeTime: "8:00 PM",
  category: FoodCategory.veg,
  image: null,
  userId: 'dummyUser1', // Placeholder UID
),
FoodDonation(
  foodName: "Vegetable Upma",
  expiryDate: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))),
  quantity: "Serves 3",
  description: "Healthy South Indian breakfast made with semolina and vegetables.",
  bestBeforeTime: "9:00 AM",
  category: FoodCategory.vegan,
  image: null,
  userId: 'dummyUser2', // Placeholder UID
),

FoodDonation(
  foodName: "Idli & Coconut Chutney",
  expiryDate: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))),
  quantity: "12 idlis + 200ml chutney",
  description: "Steamed South Indian rice cakes with fresh coconut chutney.",
  bestBeforeTime: "10:00 PM",
  category: FoodCategory.vegan,
  image: null,
  userId: 'dummyUser1', // Placeholder UID
),
FoodDonation(
  foodName: "Mix Vegetable Pulao",
  expiryDate: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 2))),
  quantity: "1.5 litres",
  description: "Fragrant rice cooked with mixed vegetables and mild spices.",
  bestBeforeTime: "9:00 PM",
  category: FoodCategory.veg,
  image: null,
  userId: 'dummyUser3', // Placeholder UID
),
// Donations added by the logged-in user will have their actual UID
  ];

  List<FoodDonation> get donations => _donations;

  // Get donations only for a specific user ID
  List<FoodDonation> getUserDonations(String userId) {
    // Ensure userId is not null or empty before filtering
     if (userId.isEmpty) return [];
    return _donations.where((d) => d.userId == userId).toList();
  }


  void addDonation(FoodDonation donation) {
    // Add to the beginning of the list so new items appear first
    _donations.insert(0, donation);
    notifyListeners();
  }

  void removeDonation(String id) {
    _donations.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}

// ---------------------------- DONATE FOOD SCREEN (Uses Firebase User) ----------------------------

class DonateFoodScreen extends StatefulWidget {
  const DonateFoodScreen({super.key});

  @override
  State<DonateFoodScreen> createState() => _DonateFoodScreenState();
}

class _DonateFoodScreenState extends State<DonateFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bestBeforeTimeController =
      TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker(); // Use instance variable
  FoodCategory _selectedCategory = FoodCategory.veg; // Default selection
  DateTime? _selectedExpiryDate;
  TimeOfDay? _selectedBestBeforeTime;

  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

  @override
   void initState() {
     super.initState();
      // Check if user is logged in when the screen is initialized
      if (_currentUserId == null) {
         // If user is not logged in, show a message and navigate back
         Future.microtask(() { // Use microtask to avoid build errors
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Please log in to add a donation.'),
               backgroundColor: Theme.of(context).colorScheme.error,
               behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
             ),
           );
           Navigator.pop(context); // Go back to the previous screen (Home)
         });
      }
   }


  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      ); // Compress image

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        debugPrint('No image selected.');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking image. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
     if (_currentUserId == null) {
         // Should have been caught by initState, but double check
         print("Attempted to pick image while logged out.");
         return;
      }
    showModalBottomSheet(
      // Use bottom sheet for modern feel
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, // Use card color for bottom sheet background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          // Ensure content doesn't overlap system UI
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(), // Can't select past dates
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Limit to 1 year
      helpText: 'Select Expiry Date',
      builder: (context, child) {
        // Apply theme to picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
               onSurface: Theme.of(context).colorScheme.onSurface, // Ensure text color is visible
              surface: Theme.of(context).colorScheme.surfaceContainerHighest, // Background of picker
            ),
             textButtonTheme: TextButtonThemeData( // Style the OK/Cancel buttons
               style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary, // Use primary color for buttons
               ),
            )
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = pickedDate;
        _expiryDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(pickedDate);
      });
    }
  }

  Future<void> _selectBestBeforeTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedBestBeforeTime ?? TimeOfDay.now(),
      helpText: 'Select Best Before Time',
       builder: (context, child) {
        // Apply theme to picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
               onSurface: Theme.of(context).colorScheme.onSurface, // Ensure text color is visible
              surface: Theme.of(context).colorScheme.surfaceContainerHighest, // Background of picker
            ),
             textButtonTheme: TextButtonThemeData( // Style the OK/Cancel buttons
               style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary, // Use primary color for buttons
               ),
            )
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedBestBeforeTime) {
      setState(() {
        _selectedBestBeforeTime = pickedTime;
        _bestBeforeTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _submitDonation() {
     if (_currentUserId == null) {
         // Should have been caught by initState, but double check
         print("Attempted to submit donation while logged out.");
         return;
      }

    if (_formKey.currentState!.validate()) {
      // All fields are valid
      final donationProvider = Provider.of<DonationProvider>(
        context,
        listen: false,
      );

      final newDonation = FoodDonation(
        foodName: _foodNameController.text.trim(),
        expiryDate: _expiryDateController.text,
        image: _image?.path,
        quantity: _quantityController.text.trim(),
        description: _descriptionController.text.trim(),
        bestBeforeTime: _bestBeforeTimeController.text,
        category: _selectedCategory,
        userId: _currentUserId!, // Assign the actual Firebase current user ID
      );

      donationProvider.addDonation(newDonation);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Donation added successfully! Thank you.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Clear form and navigate back
      _formKey.currentState?.reset();
      _foodNameController.clear();
      _expiryDateController.clear();
      _quantityController.clear();
      _descriptionController.clear();
      _bestBeforeTimeController.clear();
      setState(() {
        _image = null;
        _selectedCategory = FoodCategory.veg;
        _selectedExpiryDate = null;
        _selectedBestBeforeTime = null;
      });

      Navigator.pop(context); // Go back to home screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields correctly.'),
          backgroundColor: Colors.orangeAccent, // Warning color
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _expiryDateController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _bestBeforeTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

     // Show loading or error if user is null initially
     if (_currentUserId == null) {
         return Scaffold(appBar: AppBar(title: Text('Add New Donation')), body: const Center(child: CircularProgressIndicator()));
     }

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Donation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Make button full width
            children: [
              Center(
                // Center the image picker
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerHighest, // Use card color for placeholder bg
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _image == null
                            ? colorScheme.outline.withOpacity(0.5)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              14,
                            ), // Slightly smaller radius than container
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : Column(
                            // Placeholder content
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: colorScheme.onSurfaceVariant,
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Food Photo (Optional)', // Made optional as network images are used if null
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name *',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity * (e.g., 2 packs, 500g)',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date *',
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                readOnly: true,
                onTap: () => _selectExpiryDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the expiry date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _bestBeforeTimeController,
                decoration: const InputDecoration(
                  labelText: 'Best Before Time *',
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                readOnly: true,
                onTap: () => _selectBestBeforeTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the best before time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              // Dropdown using DropdownButtonFormField for better integration and validation
              DropdownButtonFormField<FoodCategory>(
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                value: _selectedCategory,
                // Use the enum's display name for the text
                items: FoodCategory.values.map((category) {
                  return DropdownMenuItem<FoodCategory>(
                    value: category,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
                dropdownColor:
                    colorScheme.surfaceContainerHighest, // Match card color for dropdown background
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description * (allergens, details)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitDonation,
                child: const Text('Add Donation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//---------------------------- REQUEST FOOD PROVIDER AND SCREEN (Uses Firebase User) ----------------------------

class FoodRequest {
  final String id; // Unique ID for requests
  final String foodName;
  final String quantity;
  final String description;
  final DateTime requestTime; // Add timestamp
  final String userId; // Added user ID

  FoodRequest({
    required this.foodName,
    required this.quantity,
    required this.description,
    required this.userId, // User ID is now required
  })  : requestTime = DateTime.now(),
        id = DateTime.now().millisecondsSinceEpoch.toString(); // Simple unique ID
}

class RequestProvider extends ChangeNotifier {
  final List<FoodRequest> _requests = [];

  List<FoodRequest> get requests => _requests;

   // Get requests only for a specific user ID
  List<FoodRequest> getUserRequests(String userId) {
     // Ensure userId is not null or empty before filtering
     if (userId.isEmpty) return [];
    return _requests.where((r) => r.userId == userId).toList();
  }


  void addRequest(FoodRequest request) {
    _requests.insert(0, request); // Add new requests to the top
    notifyListeners();
  }

  void removeRequest(FoodRequest request) {
    _requests.removeWhere((r) => r.id == request.id); // Remove by ID for safety
    notifyListeners();
  }
}

class RequestFoodScreen extends StatefulWidget {
  const RequestFoodScreen({super.key});

  @override
  State<RequestFoodScreen> createState() => _RequestFoodScreenState();
}

class _RequestFoodScreenState extends State<RequestFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // Now mandatory

  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

  @override
   void initState() {
     super.initState();
      // Check if user is logged in when the screen is initialized
      if (_currentUserId == null) {
         // If user is not logged in, show a message and navigate back
         Future.microtask(() { // Use microtask to avoid build errors
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Please log in to make a request.'),
               backgroundColor: Theme.of(context).colorScheme.error,
               behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
             ),
           );
           Navigator.pop(context); // Go back to the previous screen (Home)
         });
      }
   }


  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitRequest() {
     if (_currentUserId == null) {
         // Should have been caught by initState, but double check
         print("Attempted to submit request while logged out.");
         return;
      }

    if (_formKey.currentState!.validate()) {
      final newRequest = FoodRequest(
        foodName: _foodNameController.text.trim(),
        quantity: _quantityController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: _currentUserId!, // Assign the actual Firebase current user ID
      );

      // Add request using Provider
      Provider.of<RequestProvider>(
        context,
        listen: false,
      ).addRequest(newRequest);

      print('Food Request Submitted by User $_currentUserId:');
      print('  Food Name: ${newRequest.foodName}');
      print('  Quantity: ${newRequest.quantity}');
      print('  Description: ${newRequest.description}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Food request submitted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Clear the form and navigate back
      _formKey.currentState?.reset();
      _foodNameController.clear();
      _quantityController.clear();
      _descriptionController.clear();
      Navigator.pop(context); // Go back after successful submission
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields.'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     // Show loading or error if user is null initially
     if (_currentUserId == null) {
         return Scaffold(appBar: AppBar(title: Text('Request Food Item')), body: const Center(child: CircularProgressIndicator()));
     }


    return Scaffold(
      appBar: AppBar(title: const Text('Request Food Item')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  // Add introductory text
                  'Need a specific food item? Let donors know what you\'re looking for.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _foodNameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Item Name *',
                    prefixIcon: Icon(Icons.shopping_basket_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Required Quantity * (e.g., 1 bottle, 2 kg)',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the required quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText:
                        'Reason / Description * (Why you need it, specifics)',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a reason or description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitRequest,
                  child: const Text('Submit Food Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//---------------------------- CHAT PROVIDER ----------------------------

class ChatProvider extends ChangeNotifier {
  // Placeholder for chat management logic.
  // In a real app, this would handle storing and retrieving messages
  // possibly grouped by donation ID or involved users.

  // Example structure (replace with actual implementation):
  // Maps chatId (e.g., donationId) -> List of ChatMessage
  final Map<String, List<ChatMessage>> _chats = {};

  void addMessage(String chatId, ChatMessage message) {
    // Ensure the list exists for the given chatId
    if (!_chats.containsKey(chatId)) {
      _chats[chatId] = [];
    }
    _chats[chatId]!.add(message);
    notifyListeners();
  }

  List<ChatMessage> getMessages(String chatId) {
    // Return messages for a specific chat ID, or an empty list if no chat exists
    // Return a *copy* to prevent external modification of the internal list
    return List.from(_chats[chatId] ?? []);
  }

  void clearChat(String chatId) {
     _chats.remove(chatId);
     notifyListeners();
  }
   // In a real app, you'd also need methods to load/save chats from storage/backend
   // and potentially filter messages by involved users.
}

//---------------------------- GEMINI SCREEN (Optional, requires key) ----------------------------

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  State<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  final _promptController = TextEditingController();
  String _outputText = 'Enter a prompt and tap Ask Assistant.';
  bool _isLoading = false;
  String _errorMessage = '';

   final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

   @override
   void initState() {
     super.initState();
      // Check if user is logged in when the screen is initialized
      if (_currentUserId == null) {
         // If user is not logged in, show a message and navigate back
         Future.microtask(() { // Use microtask to avoid build errors
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Please log in to use the AI Assistant.'),
               backgroundColor: Theme.of(context).colorScheme.error,
               behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
             ),
           );
           Navigator.pop(context); // Go back to the previous screen (Home)
         });
      }
   }


 Future<void> _generateText() async {
    // Check if user is logged in
     if (_currentUserId == null) {
        print("Attempted to use Gemini while logged out.");
        _showLoginRequiredMessage(); // Show message if not logged in
        return;
     }


  setState(() {
    _isLoading = true;
    _errorMessage = '';
    _outputText = ''; // Clear previous output
  });

  // Using String.fromEnvironment allows setting this securely during build
  // Example: flutter run --dart-define="UNSPLASH_ACCESS_KEY=YOUR_ACCESS_KEY"
  const String apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AIzaSyD6N11putqjtqbf6n69a5GT_Vv-wdWvmXQ'); // Get key securely

  if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY') { // Check if the key is missing or the default placeholder
      setState(() {
        _errorMessage = 'Gemini API key not configured.';
        _isLoading = false;
      });
      print('Gemini API Error: API key is missing or using placeholder.');
      return;
  }


  try {
    final gemini = GenerativeModel(
      model: 'gemini-2.0-flash', // Use 'gemini-1.5' or 'gemini-pro' if needed
      apiKey: apiKey,
    );


    final prompt = _promptController.text;
    if (prompt.isEmpty) {
         setState(() {
           _errorMessage = 'Please enter a prompt.';
           _isLoading = false;
         });
         return;
    }

    final content = [Content.text(prompt)];

    // Using generateContentStream for streaming responses
    final responseStream = gemini.generateContentStream(content);

    await for (final chunk in responseStream) {
      setState(() {
        _outputText += chunk.text ?? '';
      });
    }
  } on GenerativeAIException catch (e) {
     setState(() {
       // More user-friendly message for common AI errors
       _errorMessage = 'AI Error: ${e.message}. Please try again.';
        _outputText = ''; // Clear output on error
     });
      print('Gemini API GenerativeAIException: ${e.message}');
  }
  catch (e) {
    setState(() {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
       _outputText = ''; // Clear output on error
    });
    print('Gemini API General Error: ${e.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

   void _showLoginRequiredMessage() {
         ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please log in to use the AI Assistant.'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
    }


  @override
  Widget build(BuildContext context) {
     // Show loading or error if user is null initially
     if (_currentUserId == null) {
         return Scaffold(appBar: AppBar(title: Text('AI Assistant')), body: const Center(child: CircularProgressIndicator()));
     }


    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: 'Ask about food safety, recipes, etc.',
                hintText: 'e.g., "How long can cooked rice be stored?", "Suggest a recipe for leftover chicken."',
                border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateText,
              child: _isLoading
                  ? SizedBox( // Use SizedBox for consistent height
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Ask Assistant'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText( // Use SelectableText to allow copying the response
                  _outputText.isEmpty && !_isLoading && _errorMessage.isEmpty ? 'Enter a prompt above to get started.' : _outputText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------------------- PROFILE SCREEN (Uses Firebase User) ----------------------------

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // Get the current logged-in user
  final User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

     // If somehow reached without a logged-in user (StreamBuilder should prevent)
     if (currentUser == null) {
        // You could show an error or redirect
        return Scaffold(
          appBar: AppBar(title: Text('Profile')),
          body: const Center(child: Text("Please log in to view your profile.")),
        );
     }


    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              // Display user's photoURL if available, otherwise placeholder
              backgroundImage: currentUser?.photoURL != null
                  ? CachedNetworkImageProvider(currentUser!.photoURL!) as ImageProvider<Object>?
                  : null,
              child: currentUser?.photoURL == null
                  ? Icon(
                      Icons.account_circle_outlined,
                      size: 80,
                      color: colorScheme.primary,
                    ) // Placeholder profile icon
                  : null,
            ),
            const SizedBox(height: 20),
            // Display user's email or UID
            Text(
              currentUser?.email ?? 'User ID: ${currentUser?.uid ?? "N/A"}',
              style: textTheme.titleLarge,
            ),
             if (currentUser?.email != null) // Show UID if email is available
               Text(
                 'User ID: ${currentUser?.uid ?? "N/A"}',
                  style: textTheme.bodyMedium,
               ),

            const SizedBox(height: 8),
            Text(
              'PlateMate Member', // Placeholder status
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            Divider(color: colorScheme.outline), // Separator

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Activity',
                style: textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 10),

            Card( // Use Card for better visual grouping
              margin: EdgeInsets.zero, // Remove default card margin
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.food_bank_outlined),
                    title: const Text('My Listed Food'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                       // Ensure currentUser is not null before navigating
                       if (currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserDonationsScreen()),
                          );
                       }
                    },
                  ),
                   Divider(height: 1, color: colorScheme.outline, indent: 16, endIndent: 16,), // Separator within card
                   ListTile(
                    leading: const Icon(Icons.request_page_outlined),
                    title: const Text('My Food Requests'),
                    trailing: const Icon(Icons.chevron_right),
                     onTap: () {
                         // Ensure currentUser is not null before navigating
                       if (currentUser != null) {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const UserRequestsScreen()),
                           );
                       }
                     },
                  ),
                  // Add other list tiles for activity like Messages, Pickup History etc.
                ],
              ),
            ),

             const SizedBox(height: 30),
            Divider(color: colorScheme.outline), // Separator
             const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: textTheme.titleLarge,
              ),
            ),
             const SizedBox(height: 10),

            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('App Settings'),
                     trailing: const Icon(Icons.chevron_right),
                     onTap: () {
                       // TODO: Navigate to Settings Screen
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                           content: Text('Settings not implemented yet.'),
                           behavior: SnackBarBehavior.floating,
                         ),
                       );
                     },
                  ),
                   Divider(height: 1, color: colorScheme.outline, indent: 16, endIndent: 16,),
                   ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent), // Red icon for logout
                    title: const Text('Logout'),
                     trailing: const Icon(Icons.chevron_right),
                     onTap: () {
                       // Implement Logout Logic
                        showDialog( // Show a confirmation dialog for logout
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                               backgroundColor: colorScheme.surface,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(15),
                               ),
                              title: Text('Logout', style: textTheme.titleLarge),
                              content: Text('Are you sure you want to logout?', style: textTheme.bodyMedium),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // Close dialog
                                     try {
                                        await FirebaseAuth.instance.signOut();
                                        // Firebase auth state changes and StreamBuilder in FoodDonationApp
                                        // will automatically navigate back to LoginPage
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Logged out successfully.'),
                                            backgroundColor: colorScheme.primary,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                     } catch (e) {
                                        print("Logout Error: $e");
                                         ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Logout failed: ${e.toString()}'),
                                            backgroundColor: colorScheme.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                     }

                                  },
                                   style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );
                     },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------------------- USER DONATIONS SCREEN (Your Listed Food - Uses Firebase User) ----------------------------

class UserDonationsScreen extends StatelessWidget {
  const UserDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donationProvider = Provider.of<DonationProvider>(context);
     // Get the current logged-in user's UID
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // If somehow reached without a logged-in user
     if (currentUserId == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Your Listed Food')),
          body: const Center(child: Text("Please log in to view your donations.")),
        );
     }

    // Filter donations for the current user
    final userDonations = donationProvider.getUserDonations(currentUserId);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Listed Food'),
      ),
      body: userDonations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined, // Icon for no listed items
                    size: 60,
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t listed any food yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Tap the Donate button on the Home screen to share food.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: userDonations.length,
              itemBuilder: (context, index) {
                final donation = userDonations[index];
                return Card(
                   // Use CardTheme defined globally
                   margin: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical margin between cards
                    clipBehavior: Clip.antiAlias,
                    child: InkWell( // Make the card tappable
                      onTap: () {
                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DonationDetailsScreen(
                                  donation: donation,
                                ),
                              ),
                            );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            SizedBox(
                               width: 80,
                               height: 80,
                               child: ClipRRect(
                                 borderRadius: BorderRadius.circular(8),
                                 child: Hero(
                                   tag: 'donation_image_${donation.id}', // Use same tag as Home/Details
                                   child: donation.image != null
                                      ? Image.file(
                                          File(donation.image!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => _buildSmallPlaceholderImage(context),
                                        )
                                      : FutureBuilder<String>( // Use FutureBuilder for network images
                                          future: getUnsplashImage(donation.foodName),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return _buildSmallPlaceholderImage(context, loading: true);
                                            } else if (snapshot.hasError || !snapshot.hasData) {
                                               return _buildSmallPlaceholderImage(context);
                                            } else {
                                               return CachedNetworkImage(
                                                  imageUrl: snapshot.data!,
                                                  fit: BoxFit.cover,
                                                   placeholder: (context, url) => _buildSmallPlaceholderImage(context, loading: true),
                                                   errorWidget: (context, url, error) => _buildSmallPlaceholderImage(context),
                                                );
                                            }
                                          },
                                        ),
                                 ),
                               ),
                            ),
                             const SizedBox(width: 12),
                            // Text Details Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donation.foodName,
                                    style: textTheme.titleLarge?.copyWith(fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Qty: ${donation.quantity}",
                                    style: textTheme.bodyMedium,
                                     maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                   const SizedBox(height: 4),
                                  Text(
                                    "Expires: ${donation.expiryDate}",
                                    style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                                     maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                   const SizedBox(height: 4),
                                   Text(
                                    "Best Before: ${donation.bestBeforeTime}",
                                    style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                                     maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                   const SizedBox(height: 8), // Spacer before description preview
                                   Text(
                                    donation.description,
                                    style: textTheme.bodyMedium,
                                    maxLines: 2, // Show a couple of lines of description
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                             // Action Button Section (Optional: Add Edit/Delete here)
                             // For now, delete is added on the details screen
                          ],
                        ),
                      ),
                    ),
                );
              },
            ),
    );
  }

   Widget _buildSmallPlaceholderImage(BuildContext context, {bool loading = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: loading
           ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).colorScheme.primary,))
           : Icon(
              Icons.fastfood_outlined,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
              size: 30,
            ),
      ),
    );
  }
}

//---------------------------- USER REQUESTS SCREEN (Your Food Requests - Uses Firebase User) ----------------------------

class UserRequestsScreen extends StatelessWidget {
  const UserRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    // Get the current logged-in user's UID
     final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

     // If somehow reached without a logged-in user
     if (currentUserId == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Your Food Requests')),
          body: const Center(child: Text("Please log in to view your requests.")),
        );
     }

    // Filter requests for the current user
    final userRequests = requestProvider.getUserRequests(currentUserId);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Food Requests'),
      ),
      body: userRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined, // Icon for no requests
                    size: 60,
                     color:
                        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t made any food requests yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                     textAlign: TextAlign.center,
                  ),
                   Text(
                    'Tap the Request Food button on the Home screen to make a request.',
                    style: Theme.of(context).textTheme.bodyMedium,
                     textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: userRequests.length,
              itemBuilder: (context, index) {
                final request = userRequests[index];
                // Use Dismissible for swipe-to-delete
                return Dismissible(
                   key: Key(request.id), // Unique key for Dismissible
                   direction: DismissDirection.endToStart, // Swipe from right to left
                   background: Container( // Background when swiping
                     color: Colors.redAccent,
                     alignment: Alignment.centerRight,
                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                     child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                   ),
                   confirmDismiss: (direction) async { // Show confirmation dialog before dismissing
                     return await showDialog(
                       context: context,
                       builder: (BuildContext context) {
                         return AlertDialog(
                           backgroundColor: colorScheme.surface,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                           ),
                           title: Text("Delete Request?", style: textTheme.titleLarge),
                           content: Text(
                             "Are you sure you want to delete your request for \"${request.foodName}\"? This action cannot be undone.",
                             style: textTheme.bodyMedium,
                           ),
                           actions: <Widget>[
                             TextButton(
                               onPressed: () => Navigator.of(context).pop(false), // Return false to cancel
                               child: Text("Cancel", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                             ),
                             ElevatedButton(
                               onPressed: () => Navigator.of(context).pop(true), // Return true to dismiss
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                               child: const Text("Delete"),
                             ),
                           ],
                         );
                       },
                     );
                   },
                   onDismissed: (direction) { // Action after confirmed dismissal
                      // Remove the request from the provider
                     Provider.of<RequestProvider>(context, listen: false).removeRequest(request);
                      // Show a confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${request.foodName} request deleted.'),
                           backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                   },
                   child: Card(
                     margin: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical margin
                     child: ListTile(
                       leading: Icon(Icons.shopping_basket_outlined, color: colorScheme.primary),
                       title: Text(request.foodName, style: textTheme.titleLarge?.copyWith(fontSize: 18)),
                       subtitle: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const SizedBox(height: 4),
                           Text("Qty: ${request.quantity}", style: textTheme.bodyMedium),
                            const SizedBox(height: 4),
                           Text("Requested: ${DateFormat('yyyy-MM-dd HH:mm').format(request.requestTime)}", style: textTheme.bodySmall?.copyWith(fontSize: 11)),
                            const SizedBox(height: 4),
                           Text("Details: ${request.description}", style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis,),
                         ],
                       ),
                        isThreeLine: true, // Allow more space for subtitle
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjust padding
                       // Add a trailing icon or button if needed (e.g., to edit)
                       // trailing: Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                       onTap: () {
                         // TODO: Implement view/edit request details
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Viewing details for "${request.foodName}" request.'),
                             behavior: SnackBarBehavior.floating,
                           ),
                         );
                       },
                     ),
                   ),
                );
              },
            ),
    );
  }
}


//---------------------------- UNSPLASH API INTEGRATION (Keep as is) ----------------------------

Future<String> getUnsplashImage(String query) async {
  // Using String.fromEnvironment allows setting this securely during build
  // Example: flutter run --dart-define="UNSPLASH_ACCESS_KEY=YOUR_ACCESS_KEY"
  const String accessKey = String.fromEnvironment('UNSPLASH_ACCESS_KEY', defaultValue: 'Vhlwl0DoR5JOcpNXZriCMA99wrxCftlsTR8yW9XePak'); // Replace with your Unsplash key

   // Fallback default image URL if API fails or no key is provided
   const String defaultImageUrl = 'https://images.unsplash.com/photo-1490818387583-1c6d35660ca2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Zm9vZCUyMHBsYWNlaG9sZGVyfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60';

    if (accessKey.isEmpty || accessKey == 'YOUR_ACCESS_KEY') { // Check if key is missing or placeholder
       print("Unsplash API Error: Access key is missing or using placeholder. Using default image.");
       return defaultImageUrl;
    }


   // Add parameters for relevance and orientation
  final url =
      'https://api.unsplash.com/search/photos?query=$query food&per_page=1&orientation=landscape&client_id=$accessKey'; // Added ' food' to query

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['urls']['regular']; // Return the image URL
      } else {
        // No results found for the specific query
        print("No Unsplash results for '$query'. Using default.");
        return defaultImageUrl;
      }
    } else {
      // API error
      print("Failed to load images from Unsplash. Status: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Print body for debugging API errors
       return defaultImageUrl; // Return Default Image on API error
    }
  } catch (e) {
    // Network or parsing error
    print("Error fetching Unsplash image: $e");
    return defaultImageUrl; // Return Default Image on exception
  }
}
