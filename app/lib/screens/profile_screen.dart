import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart' show ItemOverview, ServerInfo, UserProfile, UserRatingDetail;
import 'package:shareloop/app_config.dart';
import 'package:shareloop/screens/edit_profile_screen.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/screens/settings_screen.dart';
import 'package:shareloop/theme/app_theme.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/profile.dart';
import 'package:shareloop/state/seeding.dart';
import 'package:shareloop/widgets/rating_stars.dart';

class ProfileScreen extends ConsumerWidget {
  final int? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final serverInfo = ref.watch(serverInfoProvider);

    return currentUser.when(
      loading: () => const Scaffold(
        appBar: _ProfileAppBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        appBar: _ProfileAppBar(),
        body: Center(child: Text('Authentifizierung fehlgeschlagen')),
      ),
      data: (user) {
        if (user == null && userId == null) {
          return Scaffold(
            appBar: const _ProfileAppBar(),
            body: _notLoggedIn(context, ref, serverInfo),
          );
        }
        final targetUserId = userId ?? user!.id;
        final isOwnProfile = user != null && targetUserId == user.id;
        return _ProfileContent(
          userId: targetUserId,
          isOwnProfile: isOwnProfile,
        );
      },
    );
  }

  Widget _notLoggedIn(
    BuildContext ctx,
    WidgetRef ref,
    AsyncValue<ServerInfo?> serverInfo,
  ) {
    final seedingAvailable =
        serverInfo.whenOrNull(data: (d) => d)?.seeding != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nicht angemeldet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => LoginScreen.push(ctx),
              child: const Text('Anmelden'),
            ),
            if (seedingAvailable) ...[
              const SizedBox(height: 24),
              _SeedButton(ctx),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Profil'), centerTitle: false);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProfileContent extends ConsumerWidget {
  final int userId;
  final bool isOwnProfile;

  const _ProfileContent({
    required this.userId,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(userProfileProvider(userId));
    final asyncItems = ref.watch(userItemsProvider(userId));
    final asyncRatings = ref.watch(userRatingsProvider(userId));

    return asyncProfile.when(
      data: (profile) {
        final items = asyncItems.value ?? [];
        final ratings = asyncRatings.value ?? [];
        return _buildPage(context, ref, profile, items, ratings);
      },
      loading: () => Scaffold(
        appBar: _appBar(context, ref, null),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: _appBar(context, ref, null),
        body: Center(child: Text('$e')),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, WidgetRef ref, UserProfile? profile) {
    return AppBar(
      title: const Text('Profil'),
      centerTitle: false,
      actions: [
        if (isOwnProfile && profile != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await EditProfileScreen.push(context, profile);
              if (result == true) {
                ref.invalidate(userProfileProvider(userId));
              }
            },
          ),
        if (isOwnProfile) ...[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => SettingsScreen.push(context),
          ),
        ],
      ],
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    List<ItemOverview> items,
    List<UserRatingDetail> ratings,
  ) {
    return Scaffold(
      appBar: _appBar(context, ref, profile),
      body: _buildBody(context, ref, profile, items, ratings),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    List<ItemOverview> items,
    List<UserRatingDetail> ratings,
  ) {
    final months = _monthsSince(profile.createdAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _ProfileHeader(name: profile.name, avatarUuid: profile.avatarUuid)),
          const SizedBox(height: 16),
          _StatsRow(profile: profile, months: months),
          const SizedBox(height: 16),
          if (!isOwnProfile) ... [
            _FollowButton(userId: userId, isFollowed: profile.isFollowed),
            const SizedBox(height: 16),
          ],
          if (profile.bio != null && profile.bio!.isNotEmpty) ... [
            _BioSection(bio: profile.bio!),
            const SizedBox(height: 16),
          ],
          _SectionTitle(title: 'Inserate (${items.length})'),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ItemCard(item: item),
          )),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Keine Inserate'),
            ),
          _SectionTitle(title: 'Bewertungen (${ratings.length})'),
          const SizedBox(height: 8),
          ...ratings.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RatingCard(rating: r),
          )),
          if (ratings.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Keine Bewertungen'),
            ),
        ],
      ),
    );
  }

  int _monthsSince(DateTime date) {
    final now = DateTime.now();
    return (now.year - date.year) * 12 + (now.month - date.month);
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String? avatarUuid;

  const _ProfileHeader({required this.name, this.avatarUuid});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: avatarUuid != null
              ? NetworkImage(AppConfig.imageUrl(avatarUuid!))
              : null,
          child: avatarUuid == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 36),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserProfile profile;
  final int months;

  const _StatsRow({required this.profile, required this.months});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(
          label: 'Bewertung',
          value: profile.rating != null
              ? '${profile.rating!.toStringAsFixed(1)} / 5'
              : '\u2013',
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatBox(
          label: 'Verleihe',
          value: '${profile.shareCount ?? 0}',
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatBox(
          label: 'Abonnenten',
          value: '${profile.followerCount ?? 0}',
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatBox(
          label: 'Mitglied',
          value: '$months/M',
        )),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _FollowButton extends ConsumerStatefulWidget {
  final int userId;
  final bool? isFollowed;

  const _FollowButton({required this.userId, required this.isFollowed});

  @override
  ConsumerState<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<_FollowButton> {
  bool _loading = false;

  Future<void> _toggle() async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      if (!mounted) return;
      await LoginScreen.push(context);
      return;
    }
    setState(() => _loading = true);
    try {
      if (widget.isFollowed == true) {
        await AppConfig.apiClient.unfollowUser(widget.userId);
      } else {
        await AppConfig.apiClient.followUser(widget.userId);
      }
      ref.invalidate(userProfileProvider(widget.userId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isFollowed == true ? 'Fehler beim Entfolgen' : 'Fehler beim Folgen'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _loading ? null : _toggle,
        child: _loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(widget.isFollowed == true ? 'Gefolgt' : 'Folgen'),
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  final String bio;

  const _BioSection({required this.bio});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beschreibung',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(bio),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemOverview item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemScreen(itemId: item.id),
            ),
          );
        },
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUuid != null)
            Image.network(
              AppConfig.imageUrl(item.imageUuid!),
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 150,
                child: Center(child: Icon(Icons.image)),
              ),
            )
          else
            const SizedBox(
              height: 100,
              child: Center(child: Icon(Icons.image, size: 48)),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.score.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, size: 14, color: starColor),
                  ],
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

class _RatingCard extends StatelessWidget {
  final UserRatingDetail rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final overall =
        (rating.friendliness + rating.punctuality + rating.reliability) / 3.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rating.reviewer.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ReadOnlyStars(value: overall),
              ],
            ),
            const SizedBox(height: 8),
            if (rating.comment != null && rating.comment!.isNotEmpty)
              Text(rating.comment!),
          ],
        ),
      ),
    );
  }
}

class _SeedButton extends StatelessWidget {
  final BuildContext context;

  const _SeedButton(this.context);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showSeedConfirmDialog(context),
      icon: const Icon(Icons.storage),
      label: const Text('Demo-Daten einspielen'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade100,
        foregroundColor: Colors.orange.shade900,
      ),
    );
  }

  void _showSeedConfirmDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Demo-Daten einspielen?'),
        content: const Text(
          'ACHTUNG: Dabei werden ALLE vorhandenen Daten gelöscht!\n\n'
          'Vorhandene Nutzer, Artikel, Anfragen und Nachrichten werden '
          'unwiderruflich entfernt und durch Demo-Daten ersetzt.\n\n'
          'Fortfahren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              performSeed();
            },
            child: const Text('Ja, einspielen'),
          ),
        ],
      ),
    );
  }
}
