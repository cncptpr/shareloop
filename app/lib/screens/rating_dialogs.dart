import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/state/item_detail.dart';
import 'package:shareloop/state/ratings.dart';
import 'package:shareloop/state/renting.dart';

Future<void> showUserRatingDialog(
  BuildContext context,
  WidgetRef ref,
  int requestId,
  RentRequestDetail request,
  bool isOwner,
) async {
  final revieweeName = isOwner ? request.requester.name : request.ownerName;
  final userCommentController = TextEditingController();

  int? friendliness;
  int? punctuality;
  int? reliability;
  int? roleSpecific;

  final submitted = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final userRatingComplete = friendliness != null &&
            punctuality != null &&
            reliability != null &&
            roleSpecific != null;

        return AlertDialog(
          title: Text('$revieweeName bewerten'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  RatingStars(
                    label: 'Freundlichkeit',
                    value: friendliness,
                    onChanged: (value) =>
                        setDialogState(() => friendliness = value),
                  ),
                  RatingStars(
                    label: 'Pünktlichkeit',
                    value: punctuality,
                    onChanged: (value) =>
                        setDialogState(() => punctuality = value),
                  ),
                  RatingStars(
                    label: 'Zuverlässigkeit',
                    value: reliability,
                    onChanged: (value) =>
                        setDialogState(() => reliability = value),
                  ),
                  RatingStars(
                    label: isOwner ? 'Sorgsamer Umgang' : 'Kommunikation',
                    value: roleSpecific,
                    onChanged: (value) =>
                        setDialogState(() => roleSpecific = value),
                  ),
                  TextField(
                    controller: userCommentController,
                    decoration: const InputDecoration(
                      labelText: 'Kommentar (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton.icon(
              onPressed: userRatingComplete
                  ? () {
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    }
                  : null,
              icon: const Icon(Icons.star, size: 18),
              label: const Text('Bewertung senden'),
            ),
          ],
        );
      },
    ),
  );
  if (submitted != true) {
    userCommentController.dispose();
    return;
  }
  if (!context.mounted) {
    userCommentController.dispose();
    return;
  }

  final userComment = userCommentController.text.trim();
  userCommentController.dispose();

  final rating = await submitUserRating(
    requestId: requestId,
    userRating: SubmitUserRatingRequest(
      friendliness: friendliness!,
      punctuality: punctuality!,
      reliability: reliability!,
      communication: isOwner ? null : roleSpecific!,
      carefulHandling: isOwner ? roleSpecific! : null,
      comment: userComment.isEmpty ? null : userComment,
    ),
  );
  if (!context.mounted) return;
  if (rating == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bewertung konnte nicht gespeichert werden.'),
      ),
    );
    return;
  }

  ref.invalidate(rentRequestProvider(requestId));
  ref.invalidate(myRentRequestsProvider);
}

Future<void> showItemRatingDialog(
  BuildContext context,
  WidgetRef ref,
  int requestId,
  RentRequestDetail request,
) async {
  final commentController = TextEditingController();
  int? condition;
  int? cleanliness;

  final submitted = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final ratingComplete = condition != null && cleanliness != null;
        return AlertDialog(
          title: Text('${request.itemTitle} bewerten'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  RatingStars(
                    label: 'Zustand',
                    value: condition,
                    onChanged: (value) =>
                        setDialogState(() => condition = value),
                  ),
                  RatingStars(
                    label: 'Sauberkeit',
                    value: cleanliness,
                    onChanged: (value) =>
                        setDialogState(() => cleanliness = value),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Kommentar (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton.icon(
              onPressed: ratingComplete
                  ? () {
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    }
                  : null,
              icon: const Icon(Icons.star, size: 18),
              label: const Text('Bewertung senden'),
            ),
          ],
        );
      },
    ),
  );
  if (submitted != true) {
    commentController.dispose();
    return;
  }
  if (!context.mounted) {
    commentController.dispose();
    return;
  }

  final comment = commentController.text.trim();
  commentController.dispose();
  final rating = await submitItemRating(
    requestId: requestId,
    itemRating: SubmitItemRatingRequest(
      condition: condition!,
      cleanliness: cleanliness!,
      comment: comment.isEmpty ? null : comment,
    ),
  );
  if (!context.mounted) return;
  if (rating == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gegenstandsbewertung konnte nicht gespeichert werden.'),
      ),
    );
    return;
  }

  ref.invalidate(rentRequestProvider(requestId));
  ref.invalidate(myRentRequestsProvider);
  ref.invalidate(itemDetailProvider(request.itemId));
}

class RatingStars extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  const RatingStars({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text('${value ?? 0}/5'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  constraints:
                      const BoxConstraints.tightFor(width: 40, height: 40),
                  padding: EdgeInsets.zero,
                  tooltip: '$star Sterne',
                  onPressed: () => onChanged(star),
                  icon: Icon(
                    value != null && star <= value!
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber[700],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
