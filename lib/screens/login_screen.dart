import 'package:flutter/material.dart';
import '../providers/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  
  String? _emailError;
  String? _passwordError;
  String? _nameError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _nameError = null;
    });

    bool isValid = true;

    if (!_isLogin && _nameController.text.isEmpty) {
      setState(() => _nameError = 'Name is required');
      isValid = false;
    }

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_emailController.text.contains('@')) {
      setState(() => _emailError = 'Enter a valid email');
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleAuth() async {
    if (_validateInputs()) {
      setState(() => _isLoading = true);
      final appState = AppStateProvider.of(context);
      
      try {
        if (_isLogin) {
          await appState.login(_emailController.text, _passwordController.text);
        } else {
          await appState.signup(
            _nameController.text, 
            _emailController.text, 
            _passwordController.text
          );
        }
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleGuestLogin() {
    final appState = AppStateProvider.of(context);
    appState.continueAsGuest();
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final appState = AppStateProvider.of(context);

    try {
      await appState.signInWithGoogle();
      if (mounted && appState.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _emailError = null;
      _passwordError = null;
      _nameError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D9488),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.recycling,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                Text(
                  'EcoLoop',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  'Recycle Smarter. Earn Rewards.',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Name Input (Sign Up only)
                if (!_isLogin) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: _nameError != null
                          ? Border.all(color: Colors.red, width: 1)
                          : Border.all(color: isDark ? const Color(0xFF374151) : Colors.transparent),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Your Name',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  if (_nameError != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _nameError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Email Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Email Input
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: _emailError != null
                        ? Border.all(color: Colors.red, width: 1)
                        : Border.all(color: isDark ? const Color(0xFF374151) : Colors.transparent),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'your@email.com',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                if (_emailError != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _emailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Password Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Password Input
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: _passwordError != null
                        ? Border.all(color: Colors.red, width: 1)
                        : Border.all(color: isDark ? const Color(0xFF374151) : Colors.transparent),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                if (_passwordError != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                
                if (_isLogin)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 32),
                // Login/Signup Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Toggle Auth Mode
                GestureDetector(
                  onTap: _toggleAuthMode,
                  child: Text(
                    _isLogin 
                      ? 'Don\'t have an account? Sign up'
                      : 'Already have an account? Login',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.cardColor,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                          height: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Continue as Guest Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _handleGuestLogin,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.cardColor,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Bottom Text
                Text(
                  'List → Collect → Earn Points',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
