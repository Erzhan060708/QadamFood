import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _green = Color(0xFF0A5443);
  static const _ink = Color(0xFF173B30);
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _busy = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await ApiService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await ApiService.register(_emailCtrl.text.trim(), _passwordCtrl.text,
            _nameCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' '));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted)
        setState(
            () => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateName(String? value) {
    final parts = (value ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Аты-жөніңізді енгізіңіз';
    if (parts.length < 2) return 'Аты мен тегіңізді толық жазыңыз';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email енгізіңіз';
    if (!RegExp(r'^[\w.\-+]+@[\w\-]+(\.[\w\-]+)+$').hasMatch(value.trim()))
      return 'Email форматы дұрыс емес';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Құпиясөз енгізіңіз';
    if (value.length < 6) return 'Кемінде 6 таңба енгізіңіз';
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAF7),
        appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAF7),
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: _ink)),
            title: const Text('Qadam Food',
                style: TextStyle(
                    color: _ink, fontWeight: FontWeight.w800, fontSize: 18))),
        body: SafeArea(child: LayoutBuilder(builder: (_, constraints) {
          final desktop = constraints.maxWidth > 800;
          final content = desktop
              ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(child: _visualPanel(true)),
                  const SizedBox(width: 26),
                  Expanded(child: _formPanel())
                ])
              : Column(children: [
                  _visualPanel(false),
                  const SizedBox(height: 20),
                  _formPanel()
                ]);
          return SingleChildScrollView(
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              desktop ? 26 : 18, 12, desktop ? 26 : 18, 30),
                          child: desktop
                              ? SizedBox(height: 620, child: content)
                              : content))));
        })),
      );

  Widget _visualPanel(bool desktop) => Container(
        width: double.infinity,
        height: desktop ? null : 230,
        constraints: BoxConstraints(minHeight: desktop ? 570 : 230),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: _green, borderRadius: BorderRadius.circular(24)),
        child: Stack(children: [
          Positioned.fill(
              child: Image.network(
                  'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=1200&auto=format&fit=crop&q=85',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())),
          Positioned.fill(
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                const Color(0xF20A5443),
                const Color(0xB30A5443),
                Colors.black.withValues(alpha: .15)
              ])))),
          Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .16),
                            borderRadius: BorderRadius.circular(15)),
                        child: const Icon(Icons.eco_rounded,
                            color: Colors.white, size: 27)),
                    const SizedBox(height: 20),
                    Text(
                        _isLogin ? 'Қайта қош келдіңіз.' : 'Бір қадам жасаңыз.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: desktop ? 34 : 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.8)),
                    const SizedBox(height: 8),
                    const Text(
                        'Дәмді тағамды тиімді бағамен алып, ысырапты бірге азайтамыз.',
                        style: TextStyle(
                            color: Colors.white70, height: 1.5, fontSize: 14)),
                  ])),
        ]),
      );

  Widget _formPanel() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE7EDE8)),
            borderRadius: BorderRadius.circular(24)),
        child: Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? 'Аккаунтқа кіру' : 'Тіркелу',
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.6)),
                  const SizedBox(height: 5),
                  Text(
                      _isLogin
                          ? 'Құтқарған тағамдарыңызды жалғастырыңыз.'
                          : 'Бастау үшін аты-жөніңізді енгізіңіз.',
                      style: const TextStyle(
                          color: Color(0xFF718078), fontSize: 13)),
                  const SizedBox(height: 23),
                  if (!_isLogin) ...[
                    _field(
                        controller: _nameCtrl,
                        label: 'Аты-жөні',
                        hint: 'Аты-жөніңіз',
                        icon: Icons.person_outline_rounded,
                        validator: _validateName,
                        action: TextInputAction.next,
                        capitalization: TextCapitalization.words),
                    const SizedBox(height: 14),
                  ],
                  _field(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'name@example.com',
                      icon: Icons.mail_outline_rounded,
                      type: TextInputType.emailAddress,
                      validator: _validateEmail,
                      action: TextInputAction.next),
                  const SizedBox(height: 14),
                  _field(
                      controller: _passwordCtrl,
                      label: 'Құпиясөз',
                      hint: 'Кемінде 6 таңба',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_showPassword,
                      validator: _validatePassword,
                      action: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      suffix: IconButton(
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                          icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF718078),
                              size: 20))),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFEFED),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Color(0xFFB34235), fontSize: 12)))
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                          onPressed: _busy ? null : _submit,
                          style: FilledButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13))),
                          child: _busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(_isLogin ? 'Кіру' : 'Аккаунт ашу',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 15),
                  Center(
                      child: Wrap(alignment: WrapAlignment.center, children: [
                    Text(
                        _isLogin
                            ? 'Аккаунтыңыз жоқ па? '
                            : 'Аккаунтыңыз бар ма? ',
                        style: const TextStyle(
                            color: Color(0xFF718078), fontSize: 12)),
                    GestureDetector(
                        onTap: () => setState(() {
                              _isLogin = !_isLogin;
                              _error = null;
                            }),
                        child: Text(_isLogin ? 'Тіркелу' : 'Кіру',
                            style: const TextStyle(
                                color: _green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)))
                  ])),
                ])),
      );

  Widget _field(
          {required TextEditingController controller,
          required String label,
          required String hint,
          required IconData icon,
          required String? Function(String?) validator,
          TextInputType type = TextInputType.text,
          bool obscure = false,
          TextInputAction action = TextInputAction.next,
          TextCapitalization capitalization = TextCapitalization.none,
          Widget? suffix,
          void Function(String)? onSubmitted}) =>
      TextFormField(
        controller: controller,
        keyboardType: type,
        textCapitalization: capitalization,
        obscureText: obscure,
        textInputAction: action,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: _green),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFFBFCFA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE1E8E2))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE1E8E2))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green, width: 1.5))),
      );
}
