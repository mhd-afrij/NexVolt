import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_profile_model.dart';

// account_header_card.dart
// Profile image, name, email, membership badge + edit button

class AccountHeaderCard extends StatelessWidget {
  final UserProfileModel? profile;
  final VoidCallback onEditTap;
  final VoidCallback onImageTap;

  const AccountHeaderCard({
    super.key,
    required this.profile,
    required this.onEditTap,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          // ── Avatar ──
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: (profile?.profileImageUrl.isNotEmpty == true)
                      ? CachedNetworkImageProvider(profile!.profileImageUrl)
                      : null,
                  child: (profile?.profileImageUrl.isEmpty ?? true)
                      ? Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: cs.onPrimaryContainer,
                        )
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: cs.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Name ──
          Text(
            profile?.fullName.isNotEmpty == true
                ? profile!.fullName
                : 'Nexvolt User',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),

          // ── Email ──
          Text(
            (profile?.email.isNotEmpty == true)
                ? profile!.email
                : (FirebaseAuth.instance.currentUser?.email ?? 'No email'),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),

          // ── Membership badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (profile?.membershipType ?? 'standard').toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Edit Profile button ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEditTap,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
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

// profile_stat_card.dart
// Small metric card — used in the quick stats row

class ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? cs.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
