import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreeTerms = true;
  String? _errorMessage;
  String? _successMessage;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  // ═══════════════════════════════════════════════════
  //  BRAND COLORS
  // ═══════════════════════════════════════════════════
  static const _darkGreen = Color(0xFF0A5443);
  static const _midGreen = Color(0xFF1F7A4D);
  static const _lightGreen = Color(0xFF2D9B62);
  static const _orange = Color(0xFFFF8A00);
  static const _orangeDeep = Color(0xFFE07000);
  static const _cream = Color(0xFFF5EFE6);
  static const _creamLight = Color(0xFFFBF7F0);
  static const _textDark = Color(0xFF0A2E26);
  static const _textGray = Color(0xFF6B7280);
  static const _borderGray = Color(0xFFE5E5E5);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email енгізіңіз';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Email форматы дұрыс емес';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Құпиясөз енгізіңіз';
    if (value.length < 6) return 'Кемінде 6 таңба болуы керек';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      setState(() => _errorMessage = 'Шарттармен келісіңіз');
      return;
    }

    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isLoading = true;
    });

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name = _nameCtrl.text.trim().isEmpty ? email.split('@')[0] : _nameCtrl.text.trim();

    try {
      if (_isLogin) {
        await ApiService.login(email, password);
      } else {
        await ApiService.register(email, password, name);
      }

      if (!mounted) return;

      // Сәтті кірген соң артқы бетке қайту
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _successMessage = 'Бұл функция жақында қосылады ✉️');
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          _buildBackgroundDecor(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildBackButton(),
                        const SizedBox(height: 24),
                        _buildLogo(),
                        const SizedBox(height: 28),
                        _buildTitle(),
                        const SizedBox(height: 8),
                        _buildSubtitle(),
                        const SizedBox(height: 32),
                        _buildForm(),
                        const SizedBox(height: 18),
                        _buildMessages(),
                        const SizedBox(height: 8),
                        _buildSubmitButton(),
                        const SizedBox(height: 14),
                        _buildForgotPassword(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 22),
                        _buildSocialButton(),
                        const SizedBox(height: 24),
                        _buildToggleMode(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _orange.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _midGreen.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _orange.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: _darkGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _orange.withValues(alpha: 0.25),
                _orange.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_darkGreen, _midGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _darkGreen.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      _isLogin ? 'Қайта оралуыңызбен!' : 'Қош келдіңіз!',
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: _textDark,
        letterSpacing: -0.6,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _isLogin
            ? 'Тамақты құтқаруды жалғастырыңыз'
            : 'Тамақты құтқаруға қосылыңыз',
        style: const TextStyle(
          fontSize: 15,
          color: _textGray,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin) ...[
            _buildInputField(
              controller: _nameCtrl,
              label: 'Аты-жөні',
              hint: 'Ержан',
              icon: Icons.person_outline,
              validator: (v) {
                if (!_isLogin && (v == null || v.trim().isEmpty)) return 'Атыңызды жазыңыз';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
          ],
          _buildInputField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'test@gmail.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _passwordCtrl,
            label: 'Құпиясөз',
            hint: 'Кемінде 6 таңба',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _textGray,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          if (!_isLogin) _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffix,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      enabled: !_isLoading,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: _textDark,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: _textGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: _darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _darkGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _darkGreen, size: 18),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: _isLoading
                ? null
                : (v) => setState(() => _agreeTerms = v ?? false),
            activeColor: _darkGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: const BorderSide(color: _borderGray, width: 1.5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12.5,
                color: _textGray,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Мен '),
                TextSpan(
                  text: 'Қолдану шарттарымен',
                  style: TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: _darkGreen,
                  ),
                ),
                const TextSpan(text: ' және '),
                TextSpan(
                  text: 'Құпиялылық саясатымен',
                  style: TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: _darkGreen,
                  ),
                ),
                const TextSpan(text: ' келісемін'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessages() {
    return Column(
      children: [
        if (_errorMessage != null)
          _messageBox(
            icon: Icons.error_outline_rounded,
            text: _errorMessage!,
            color: const Color(0xFFC62828),
            bg: const Color(0xFFFEEDED),
            border: const Color(0xFFF8BBD0),
          ),
        if (_successMessage != null)
          _messageBox(
            icon: Icons.check_circle_outline_rounded,
            text: _successMessage!,
            color: _midGreen,
            bg: const Color(0xFFE8F5E9),
            border: const Color(0xFFA5D6A7),
          ),
      ],
    );
  }

  Widget _messageBox({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
    required Color border,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkGreen,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: _darkGreen.withValues(alpha: 0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? 'Кіру' : 'Тіркелу',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    if (!_isLogin) return const SizedBox.shrink();
    return TextButton(
      onPressed: _isLoading ? null : _resetPassword,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Құпиясөзді ұмыттыңыз ба?',
        style: TextStyle(
          color: _darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _borderGray,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'немесе',
            style: TextStyle(
              color: _textGray.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _borderGray,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google кіру жақында қосылады'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: _borderGray, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4285F4),
                    Color(0xFFEA4335),
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Google арқылы кіру',
              style: TextStyle(
                color: _textDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'Аккаунтыңыз жоқ па?' : 'Аккаунтыңыз бар ма?',
          style: const TextStyle(
            color: _textGray,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: _isLoading ? null : _toggleMode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _darkGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _isLogin ? 'Тіркелу' : 'Кіру',
              style: const TextStyle(
                color: _darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}