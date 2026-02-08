import 'package:flutter/material.dart';

/// Status of a family member.
enum MemberStatus {
  /// The current user viewing the tree.
  currentUser,

  /// Member is online/active.
  online,

  /// Member is offline/inactive.
  offline,

  /// Member is deceased.
  deceased,
}

/// Extension methods for [MemberStatus].
extension MemberStatusExtension on MemberStatus {
  /// Get the display color for this status.
  Color get color {
    switch (this) {
      case MemberStatus.currentUser:
        return const Color(0xFF9747FF);
      case MemberStatus.online:
        return const Color(0xFF00BF4D);
      case MemberStatus.offline:
        return const Color(0xFFB0B0B0);
      case MemberStatus.deceased:
        return const Color(0xFFFF3E6C);
    }
  }

  /// Get a human-readable label for this status.
  String get label {
    switch (this) {
      case MemberStatus.currentUser:
        return 'You';
      case MemberStatus.online:
        return 'Online';
      case MemberStatus.offline:
        return 'Offline';
      case MemberStatus.deceased:
        return 'Deceased';
    }
  }

  /// Whether this status indicates the member is alive.
  bool get isAlive => this != MemberStatus.deceased;
}
