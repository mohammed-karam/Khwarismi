import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/ai_tutor/views/ai_tutor_view.dart';
import 'package:codeforcers/features/code_compiler/views/code_compiler_view.dart';
import 'package:codeforcers/features/online_friends/views/handle_entry_view.dart';
import 'package:codeforcers/features/online_friends/views/online_friends_view.dart';
import 'package:codeforcers/features/timer/views/timer_view.dart';
import 'package:flutter/material.dart';

class TodayViewBody extends StatelessWidget {
  const TodayViewBody({super.key, required this.onOpenTab});

    final void Function(int index) onOpenTab;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to solve?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'One problem at a time: watch, attempt it, then let the AI mark '
            'your answer.',
            style: TextStyle(
              fontSize: 14.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _LoopCard(
            onStart: () => onOpenTab(2),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
                                          mainAxisExtent: 142,
            ),
            children: [
              const _ActionTile(
                icon: Icons.auto_awesome_rounded,
                tint: AppColors.navy,
                title: 'Ask the AI',
                subtitle: 'Correct your answer in 3 trials',
                destination: AiTutorView(),
              ),
              const _ActionTile(
                icon: Icons.timer_outlined,
                tint: AppColors.accentBlue,
                title: 'Timed practice',
                subtitle: 'Solve against your expected time',
                destination: TimerView(),
              ),
              const _ActionTile(
                icon: Icons.code_rounded,
                tint: Color(0xFF4338CA),
                title: 'Run your code',
                subtitle: 'Compile right on your phone',
                destination: CodeCompilerView(),
              ),
              _ActionTile(
                icon: Icons.people_outline_rounded,
                tint: const Color(0xFF0E7490),
                title: 'Online friends',
                subtitle: 'See who is practising now',
                destination: AppSettings.instance.hasCodeforcesHandle
                    ? const OnlineFriendsView()
                    : const HandleEntryView(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _PhoneTipCard(),
        ],
      ),
    );
  }
}


class _LoopCard extends StatelessWidget {
  const _LoopCard({required this.onStart});

  final VoidCallback onStart;

  static const steps = [
    ('1', 'Watch a topic', 'Level 0 and Level 1 lessons with recordings.'),
    ('2', 'Attempt a problem', 'Start the timer — it knows your expected time.'),
    ('3', 'Get feedback', 'The AI hints you for 3 trials, then shows the way.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THE SOLVE LOOP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          for (final (number, title, caption) in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          caption,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Start with a topic'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.destination,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      semanticsLabel: title,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1B3B6F),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tint, size: 19),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _PhoneTipCard extends StatelessWidget {
  const _PhoneTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.phone_iphone_rounded, color: AppColors.navy, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No laptop needed — reading problems, getting hints, running '
              'code and tracking progress all work on your phone.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
