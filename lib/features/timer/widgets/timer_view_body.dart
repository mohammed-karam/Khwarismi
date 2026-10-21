import 'dart:math';

import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/timer/manager/timer_controller.dart';
import 'package:codeforcers/features/timer/problem_difficulty_func.dart';
import 'package:codeforcers/features/timer/widgets/show_stuck_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerViewBody extends StatefulWidget {
  const TimerViewBody({super.key});

  @override
  State<TimerViewBody> createState() => _TimerViewBodyState();
}

class _TimerViewBodyState extends State<TimerViewBody> {
  final TimerController _controller = TimerController.instance;
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<int> _quickPresets = const [15, 25, 45, 60];

  @override
  void initState() {
    super.initState();
    _ratingController.text = _controller.problemRating.toString();
    _controller.addListener(_onControllerUpdate);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _ratingController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    if (_controller.pendingHintMinute != null) {
      final hint = _controller.pendingHintMinute!;
      _controller.consumePendingHint();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showStuckDialog(hint, context);
      });
    }
    setState(() {});
  }

  String _formatTime(int n) => n < 10 ? '0$n' : '$n';

  double _calculateExpectedTime(int userRating, int problemRating) {
    const double baseTime = 30.0;
    final difference = problemRating - userRating;
    return baseTime * pow(2, difference / 300).toDouble();
  }

  void _showSetMinutesDialog() {
    _minutesController.text = '${_controller.totalSeconds ~/ 60}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Custom Duration',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the total practice time in minutes:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                suffixText: 'min',
                filled: true,
                fillColor: AppColors.chipBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final val = int.tryParse(_minutesController.text);
              if (val != null && val > 0 && val <= 300) {
                _controller.setDurationMinutes(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedRating = int.tryParse(_ratingController.text) ?? 1200;
    final expectedMinutes = _calculateExpectedTime(1500, parsedRating);
    final isRunning = _controller.isRunning;
    final isDone = _controller.isCompleted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Problem Timer',
        subtitle: isRunning ? 'Timer is running' : 'Practice mode',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.speed_rounded,
                          color: AppColors.accentBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Target Problem Rating',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _ratingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1400',
                        filled: true,
                        fillColor: AppColors.chipBackground,
                        prefixIcon: const Icon(
                          Icons.tag,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check_circle_outline, size: 20),
                          color: AppColors.accentBlue,
                          onPressed: () {
                            final val = int.tryParse(_ratingController.text);
                            if (val != null) {
                              _controller.setProblemRating(val);
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed >= 800 && parsed <= 3500) {
                          _controller.setProblemRating(parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProblemDifficultyFunc(
                        userRating: 1500,
                        problemRating: parsedRating,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '~${expectedMinutes.toStringAsFixed(1)} min expected',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: _controller.progress,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          backgroundColor: AppColors.chipBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDone
                                ? Colors.red
                                : isRunning
                                    ? AppColors.accentBlue
                                    : AppColors.navy,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone
                                ? Icons.timer_off_outlined
                                : isRunning
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                            size: 26,
                            color: isDone
                                ? Colors.red
                                : isRunning
                                    ? AppColors.accentBlue
                                    : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_formatTime(_controller.minutes)}:${_formatTime(_controller.seconds)}',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: isDone
                                  ? Colors.red
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDone
                                ? 'Time is up!'
                                : isRunning
                                    ? 'Keep coding...'
                                    : 'Paused',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDone
                                  ? Colors.red
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ..._quickPresets.map((mins) {
                        final isSelected =
                            (_controller.totalSeconds == mins * 60);
                        return ChoiceChip(
                          label: Text('$mins min'),
                          selected: isSelected,
                          onSelected: (_) {
                            _controller.setDurationMinutes(mins);
                          },
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          selectedColor: AppColors.navy,
                          backgroundColor: AppColors.chipBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide.none,
                          ),
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.edit, size: 14),
                        label: const Text('Custom'),
                        onPressed: _showSetMinutesDialog,
                        labelStyle: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.chipBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide.none,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _controller.reset();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isRunning) {
                              _controller.pause();
                            } else {
                              _controller.start();
                            }
                          },
                          icon: Icon(
                            isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 22,
                          ),
                          label: Text(
                            isRunning ? 'Pause' : 'Start Timer',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isRunning
                                ? const Color(0xFFE11D48)
                                : AppColors.navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            _controller.addMinutes(5);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: AppColors.navy,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '+5m',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.accentBlue,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Timer keeps running in the background even if you leave this page. Stuck hints will appear after 30 & 60 minutes.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
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
