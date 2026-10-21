import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/features/online_friends/data/repo/online_friends_repo_impl.dart';
import 'package:codeforcers/features/online_friends/manager/online_friends_cubit/online_friends_cubit.dart';
import 'package:codeforcers/features/online_friends/views/online_friends_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shown when the user has not yet provided their Codeforces handle.
/// After saving it, the user is taken to [OnlineFriendsView].
class HandleEntryView extends StatefulWidget {
  const HandleEntryView({super.key});

  @override
  State<HandleEntryView> createState() => _HandleEntryViewState();
}

class _HandleEntryViewState extends State<HandleEntryView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Pre-fill if a handle was saved before
    final saved = AppSettings.instance.codeforcesHandle;
    if (saved.isNotEmpty) _controller.text = saved;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final handle = _controller.text.trim();
    if (handle.isEmpty) {
      setState(() => _errorText = 'Please enter your Codeforces handle.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    await AppSettings.instance.setCodeforcesHandle(handle);

    if (!mounted) return;

    final cubit = OnlineFriendsCubit(
      OnlineFriendsRepoImpl(apiService: Api()),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OnlineFriendsView(cubit: cubit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.navy,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            foregroundColor: Colors.white,
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.navy, AppColors.blue],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -30,
                        right: -30,
                        child: _Circle(
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: _Circle(
                          size: 120,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      // Icon + label
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HeaderIcon(),
                              SizedBox(height: 14),
                              Text(
                                'Online Friends',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'See who is solving on Codeforces right now',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Instruction card
                _InfoCard(
                  icon: Icons.info_outline_rounded,
                  text:
                      'Enter your Codeforces handle to fetch the friends list '
                      'associated with your account.',
                ),
                const SizedBox(height: 28),

                // Label
                const Text(
                  'Your Codeforces handle',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 10),

                // Text field
                _HandleTextField(
                  controller: _controller,
                  focus: _focus,
                  errorText: _errorText,
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
                const SizedBox(height: 28),

                // Submit button
                _SubmitButton(
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header icon ─────────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.people_alt_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navy.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.navy),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Handle text field ────────────────────────────────────────────────────────

class _HandleTextField extends StatelessWidget {
  const _HandleTextField({
    required this.controller,
    required this.focus,
    required this.errorText,
    required this.onSubmitted,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String? errorText;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focus,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      textInputAction: TextInputAction.go,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-\.]')),
      ],
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.blue,
      decoration: InputDecoration(
        hintText: 'e.g. tourist',
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.alternate_email_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
        ),
      ),
    );
  }
}

// ─── Submit button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_alt_rounded,
                        size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'See Online Friends',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Decorative circle ────────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
