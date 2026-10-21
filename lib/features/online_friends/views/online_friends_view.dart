import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/online_friends/data/repo/online_friends_repo_impl.dart';
import 'package:codeforcers/features/online_friends/manager/online_friends_cubit/online_friends_cubit.dart';
import 'package:codeforcers/features/online_friends/views/handle_entry_view.dart';
import 'package:codeforcers/features/online_friends/widgets/online_friends_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnlineFriendsView extends StatefulWidget {
  const OnlineFriendsView({super.key, this.cubit});

  final OnlineFriendsCubit? cubit;

  @override
  State<OnlineFriendsView> createState() => _OnlineFriendsViewState();
}

class _OnlineFriendsViewState extends State<OnlineFriendsView> {
  OnlineFriendsCubit? _ownedCubit;

  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.cubit == null) {
      _ownedCubit = OnlineFriendsCubit(
        OnlineFriendsRepoImpl(apiService: Api()),
      );
    }
  }

  @override
  void dispose() {
    _ownedCubit?.close();
    super.dispose();
  }

  /// Navigate to [HandleEntryView] to let the user change their handle.
  /// On return, replace this screen with a fresh [OnlineFriendsView].
  void _changeHandle() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const HandleEntryView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit ?? _ownedCubit!;
    final handle = AppSettings.instance.codeforcesHandle;

    return BlocProvider<OnlineFriendsCubit>.value(
      value: cubit,
      child: BlocBuilder<OnlineFriendsCubit, OnlineFriendsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Online Friends',
              subtitle: _subtitleFor(state, handle),
              actions: [
                IconButton(
                  tooltip: 'Change handle',
                  onPressed: _changeHandle,
                  icon: const Icon(Icons.manage_accounts_rounded),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: cubit.getOnlineFriends,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: OnlineFriendsViewBody(
              query: _query,
              onQueryChanged: (value) => setState(() => _query = value),
            ),
          );
        },
      ),
    );
  }

  String _subtitleFor(OnlineFriendsState state, String handle) {
    final prefix = handle.isNotEmpty ? '@$handle · ' : '';
    if (state is OnlineFriendsLoading) return '${prefix}Checking who is online...';
    if (state is OnlineFriendsFailure) return '${prefix}Could not refresh';
    if (state is OnlineFriendsSuccess) {
      final friends = state.onlineFriendsModel.result;
      final query = _query.trim();
      if (friends.isEmpty || query.isEmpty) {
        return '$prefix${friends.length} online now';
      }
      final visible = filterOnlineFriends(friends, query).length;
      return '$prefix$visible of ${friends.length} friends';
    }
    return handle.isNotEmpty ? '@$handle' : 'Who is solving right now';
  }
}
