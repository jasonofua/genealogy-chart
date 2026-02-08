import 'package:flutter/material.dart';
import 'member_status.dart';
import 'family_relationship.dart';

/// Represents a member in a family tree.
///
/// This is the primary data model for family-specific mode.
/// It includes comprehensive fields for genealogy applications.
class FamilyMember {
  /// Unique identifier for this member.
  final String id;

  /// Full name of the member.
  final String name;

  /// First name (optional, for display).
  final String? firstName;

  /// Last name / surname (optional).
  final String? lastName;

  /// URL or path to avatar image.
  final String? avatar;

  /// URL or path to cover photo.
  final String? coverPhoto;

  /// Current status of the member.
  final MemberStatus status;

  /// Relationship type to the reference person (usually "self").
  final FamilyRelationship relationship;

  /// Generation level in the tree.
  ///
  /// Negative values are ancestors, positive are descendants.
  /// - -2: Great grandparents
  /// - -1: Grandparents
  /// - 0: Parents
  /// - 1: Self/siblings
  /// - 2: Children
  /// - 3: Grandchildren
  final int generation;

  /// Horizontal position within the generation (for ordering).
  final int position;

  /// Gender of the member.
  final Gender? gender;

  /// Date of birth.
  final DateTime? birthDate;

  /// Date of death (if deceased).
  final DateTime? deathDate;

  /// Parent IDs (can have multiple for both parents).
  final List<String> parentIds;

  /// Spouse IDs (supports multiple spouses for remarriage).
  final List<String> spouseIds;

  /// Direct children IDs.
  final List<String> childrenIds;

  /// Whether this member is on the father's side of the family.
  final bool isFatherSide;

  /// Whether this member is a registered app user.
  final bool isRegisteredUser;

  /// User ID if this is a registered user.
  final String? userId;

  /// Biography or description.
  final String? bio;

  /// Location (city, country, etc.).
  final String? location;

  /// Birth family ID (for cross-family navigation).
  final String? birthFamilyId;

  /// Linked family ID (marriage family).
  final String? linkedFamilyId;

  /// All linked families.
  final List<LinkedFamilyInfo> linkedFamilies;

  /// Cause of death (for memorial).
  final String? causeOfDeath;

  /// Burial location (for memorial).
  final String? burialLocation;

  /// Additional custom metadata.
  final Map<String, dynamic> metadata;

  const FamilyMember({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.avatar,
    this.coverPhoto,
    this.status = MemberStatus.offline,
    this.relationship = FamilyRelationship.other,
    this.generation = 0,
    this.position = 0,
    this.gender,
    this.birthDate,
    this.deathDate,
    this.parentIds = const [],
    this.spouseIds = const [],
    this.childrenIds = const [],
    this.isFatherSide = true,
    this.isRegisteredUser = false,
    this.userId,
    this.bio,
    this.location,
    this.birthFamilyId,
    this.linkedFamilyId,
    this.linkedFamilies = const [],
    this.causeOfDeath,
    this.burialLocation,
    this.metadata = const {},
  });

  /// Whether this member has multiple spouses (remarried).
  bool get hasMultipleSpouses => spouseIds.length > 1;

  /// Whether this member is deceased.
  bool get isDeceased => status == MemberStatus.deceased;

  /// Whether this member is the current user.
  bool get isCurrentUser => status == MemberStatus.currentUser;

  /// Whether this member has any linked families.
  bool get hasLinkedFamily =>
      birthFamilyId != null ||
      linkedFamilyId != null ||
      linkedFamilies.isNotEmpty;

  /// Calculate age based on birth date.
  ///
  /// Returns null if birth date is not set.
  /// If deceased, calculates age at death.
  int? get age {
    if (birthDate == null) return null;
    final endDate = deathDate ?? DateTime.now();
    return endDate.difference(birthDate!).inDays ~/ 365;
  }

  /// Get lifespan string (e.g., "1920 - 1985").
  String? get lifespan {
    if (birthDate == null) return null;
    final birthYear = birthDate!.year;
    if (deathDate != null) {
      return '$birthYear - ${deathDate!.year}';
    }
    return '$birthYear - Present';
  }

  /// Get the display name (prefers first name if available).
  String get displayName => firstName ?? name.split(' ').first;

  /// Get the status color for this member.
  Color get statusColor => status.color;

  /// Check if this member is from another family (married into current).
  bool isFromAnotherFamily(String currentFamilyId) =>
      birthFamilyId != null && birthFamilyId != currentFamilyId;

  /// Check if this member is married into another family.
  bool isMarriedToAnotherFamily(String currentFamilyId) =>
      linkedFamilyId != null && linkedFamilyId != currentFamilyId;

  /// Create a copy with updated fields.
  FamilyMember copyWith({
    String? id,
    String? name,
    String? firstName,
    String? lastName,
    String? avatar,
    String? coverPhoto,
    MemberStatus? status,
    FamilyRelationship? relationship,
    int? generation,
    int? position,
    Gender? gender,
    DateTime? birthDate,
    DateTime? deathDate,
    List<String>? parentIds,
    List<String>? spouseIds,
    List<String>? childrenIds,
    bool? isFatherSide,
    bool? isRegisteredUser,
    String? userId,
    String? bio,
    String? location,
    String? birthFamilyId,
    String? linkedFamilyId,
    List<LinkedFamilyInfo>? linkedFamilies,
    String? causeOfDeath,
    String? burialLocation,
    Map<String, dynamic>? metadata,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      status: status ?? this.status,
      relationship: relationship ?? this.relationship,
      generation: generation ?? this.generation,
      position: position ?? this.position,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      parentIds: parentIds ?? this.parentIds,
      spouseIds: spouseIds ?? this.spouseIds,
      childrenIds: childrenIds ?? this.childrenIds,
      isFatherSide: isFatherSide ?? this.isFatherSide,
      isRegisteredUser: isRegisteredUser ?? this.isRegisteredUser,
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      birthFamilyId: birthFamilyId ?? this.birthFamilyId,
      linkedFamilyId: linkedFamilyId ?? this.linkedFamilyId,
      linkedFamilies: linkedFamilies ?? this.linkedFamilies,
      causeOfDeath: causeOfDeath ?? this.causeOfDeath,
      burialLocation: burialLocation ?? this.burialLocation,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Create from JSON.
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatar: json['avatar'] as String?,
      coverPhoto: json['coverPhoto'] as String?,
      status: _parseStatus(json['status']),
      relationship: _parseRelationship(json['relationship']),
      generation: json['generation'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      gender: _parseGender(json['gender']),
      birthDate: _parseDate(json['birthDate']),
      deathDate: _parseDate(json['deathDate']),
      parentIds: _parseStringList(json['parentIds']),
      spouseIds: _parseStringList(json['spouseIds']),
      childrenIds: _parseStringList(json['childrenIds']),
      isFatherSide: json['isFatherSide'] as bool? ?? true,
      isRegisteredUser: json['isRegisteredUser'] as bool? ?? false,
      userId: json['userId'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      birthFamilyId: json['birthFamilyId'] as String?,
      linkedFamilyId: json['linkedFamilyId'] as String?,
      linkedFamilies: (json['linkedFamilies'] as List?)
              ?.map((e) => LinkedFamilyInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      causeOfDeath: json['causeOfDeath'] as String?,
      burialLocation: json['burialLocation'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'coverPhoto': coverPhoto,
      'status': status.name,
      'relationship': relationship.name,
      'generation': generation,
      'position': position,
      'gender': gender?.name,
      'birthDate': birthDate?.toIso8601String(),
      'deathDate': deathDate?.toIso8601String(),
      'parentIds': parentIds,
      'spouseIds': spouseIds,
      'childrenIds': childrenIds,
      'isFatherSide': isFatherSide,
      'isRegisteredUser': isRegisteredUser,
      'userId': userId,
      'bio': bio,
      'location': location,
      'birthFamilyId': birthFamilyId,
      'linkedFamilyId': linkedFamilyId,
      'linkedFamilies': linkedFamilies.map((e) => e.toJson()).toList(),
      'causeOfDeath': causeOfDeath,
      'burialLocation': burialLocation,
      'metadata': metadata,
    };
  }

  static MemberStatus _parseStatus(dynamic value) {
    if (value == null) return MemberStatus.offline;
    if (value is MemberStatus) return value;
    final str = value.toString().toLowerCase();
    return MemberStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == str,
      orElse: () => MemberStatus.offline,
    );
  }

  static FamilyRelationship _parseRelationship(dynamic value) {
    if (value == null) return FamilyRelationship.other;
    if (value is FamilyRelationship) return value;
    final str = value.toString().toLowerCase();
    return FamilyRelationship.values.firstWhere(
      (r) => r.name.toLowerCase() == str,
      orElse: () => FamilyRelationship.other,
    );
  }

  static Gender? _parseGender(dynamic value) {
    if (value == null) return null;
    if (value is Gender) return value;
    final str = value.toString().toLowerCase();
    return Gender.values.firstWhere(
      (g) => g.name.toLowerCase() == str,
      orElse: () => Gender.unknown,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMember &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FamilyMember(id: $id, name: $name, gen: $generation)';
}

/// Information about a linked family.
class LinkedFamilyInfo {
  final String familyId;
  final String familyName;
  final String memberId;
  final String relationshipType; // 'birth', 'marriage', 'adoption'
  final DateTime? linkedAt;

  const LinkedFamilyInfo({
    required this.familyId,
    required this.familyName,
    required this.memberId,
    required this.relationshipType,
    this.linkedAt,
  });

  bool get isBirthFamily => relationshipType == 'birth';
  bool get isMarriageFamily => relationshipType == 'marriage';
  bool get isAdoptionFamily => relationshipType == 'adoption';

  factory LinkedFamilyInfo.fromJson(Map<String, dynamic> json) {
    return LinkedFamilyInfo(
      familyId: json['familyId'] as String? ?? '',
      familyName: json['familyName'] as String? ?? 'Unknown Family',
      memberId: json['memberId'] as String? ?? '',
      relationshipType: json['relationshipType'] as String? ?? 'unknown',
      linkedAt: json['linkedAt'] != null
          ? DateTime.tryParse(json['linkedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyId': familyId,
      'familyName': familyName,
      'memberId': memberId,
      'relationshipType': relationshipType,
      'linkedAt': linkedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'LinkedFamilyInfo(familyId: $familyId, type: $relationshipType)';
}
