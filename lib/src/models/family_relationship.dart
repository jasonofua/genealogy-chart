/// Types of family relationships.
///
/// Comprehensive list of relationship types for genealogy trees.
enum FamilyRelationship {
  // Self
  self,

  // Great-great grandparents (generation -3)
  greatGreatGrandfather,
  greatGreatGrandmother,

  // Great grandparents (generation -2)
  greatGrandfather,
  greatGrandmother,

  // Grandparents (generation -1)
  grandfather,
  grandmother,

  // Parents (generation 0)
  father,
  mother,
  stepfather,
  stepmother,

  // Same generation (generation 1)
  brother,
  sister,
  halfBrother,
  halfSister,
  stepBrother,
  stepSister,
  spouse,
  exSpouse,

  // Children (generation 2)
  son,
  daughter,
  stepSon,
  stepDaughter,
  adoptedSon,
  adoptedDaughter,

  // Grandchildren (generation 3)
  grandson,
  granddaughter,

  // Great grandchildren (generation 4)
  greatGrandson,
  greatGranddaughter,

  // Extended family
  uncle,
  aunt,
  nephew,
  niece,
  cousin,

  // In-laws
  fatherInLaw,
  motherInLaw,
  brotherInLaw,
  sisterInLaw,
  sonInLaw,
  daughterInLaw,

  // Other
  other,
}

/// Extension methods for [FamilyRelationship].
extension FamilyRelationshipExtension on FamilyRelationship {
  /// Get a human-readable label for this relationship.
  String get label {
    switch (this) {
      case FamilyRelationship.self:
        return 'Self';
      case FamilyRelationship.greatGreatGrandfather:
        return 'Great-Great Grandfather';
      case FamilyRelationship.greatGreatGrandmother:
        return 'Great-Great Grandmother';
      case FamilyRelationship.greatGrandfather:
        return 'Great Grandfather';
      case FamilyRelationship.greatGrandmother:
        return 'Great Grandmother';
      case FamilyRelationship.grandfather:
        return 'Grandfather';
      case FamilyRelationship.grandmother:
        return 'Grandmother';
      case FamilyRelationship.father:
        return 'Father';
      case FamilyRelationship.mother:
        return 'Mother';
      case FamilyRelationship.stepfather:
        return 'Stepfather';
      case FamilyRelationship.stepmother:
        return 'Stepmother';
      case FamilyRelationship.brother:
        return 'Brother';
      case FamilyRelationship.sister:
        return 'Sister';
      case FamilyRelationship.halfBrother:
        return 'Half Brother';
      case FamilyRelationship.halfSister:
        return 'Half Sister';
      case FamilyRelationship.stepBrother:
        return 'Stepbrother';
      case FamilyRelationship.stepSister:
        return 'Stepsister';
      case FamilyRelationship.spouse:
        return 'Spouse';
      case FamilyRelationship.exSpouse:
        return 'Ex-Spouse';
      case FamilyRelationship.son:
        return 'Son';
      case FamilyRelationship.daughter:
        return 'Daughter';
      case FamilyRelationship.stepSon:
        return 'Stepson';
      case FamilyRelationship.stepDaughter:
        return 'Stepdaughter';
      case FamilyRelationship.adoptedSon:
        return 'Adopted Son';
      case FamilyRelationship.adoptedDaughter:
        return 'Adopted Daughter';
      case FamilyRelationship.grandson:
        return 'Grandson';
      case FamilyRelationship.granddaughter:
        return 'Granddaughter';
      case FamilyRelationship.greatGrandson:
        return 'Great Grandson';
      case FamilyRelationship.greatGranddaughter:
        return 'Great Granddaughter';
      case FamilyRelationship.uncle:
        return 'Uncle';
      case FamilyRelationship.aunt:
        return 'Aunt';
      case FamilyRelationship.nephew:
        return 'Nephew';
      case FamilyRelationship.niece:
        return 'Niece';
      case FamilyRelationship.cousin:
        return 'Cousin';
      case FamilyRelationship.fatherInLaw:
        return 'Father-in-Law';
      case FamilyRelationship.motherInLaw:
        return 'Mother-in-Law';
      case FamilyRelationship.brotherInLaw:
        return 'Brother-in-Law';
      case FamilyRelationship.sisterInLaw:
        return 'Sister-in-Law';
      case FamilyRelationship.sonInLaw:
        return 'Son-in-Law';
      case FamilyRelationship.daughterInLaw:
        return 'Daughter-in-Law';
      case FamilyRelationship.other:
        return 'Other';
    }
  }

  /// Get the typical generation offset for this relationship.
  ///
  /// Negative values are ancestors, positive are descendants.
  /// 0 is same generation as reference person.
  int get generationOffset {
    switch (this) {
      case FamilyRelationship.greatGreatGrandfather:
      case FamilyRelationship.greatGreatGrandmother:
        return -3;
      case FamilyRelationship.greatGrandfather:
      case FamilyRelationship.greatGrandmother:
        return -2;
      case FamilyRelationship.grandfather:
      case FamilyRelationship.grandmother:
        return -1;
      case FamilyRelationship.father:
      case FamilyRelationship.mother:
      case FamilyRelationship.stepfather:
      case FamilyRelationship.stepmother:
      case FamilyRelationship.fatherInLaw:
      case FamilyRelationship.motherInLaw:
      case FamilyRelationship.uncle:
      case FamilyRelationship.aunt:
        return -1;
      case FamilyRelationship.self:
      case FamilyRelationship.brother:
      case FamilyRelationship.sister:
      case FamilyRelationship.halfBrother:
      case FamilyRelationship.halfSister:
      case FamilyRelationship.stepBrother:
      case FamilyRelationship.stepSister:
      case FamilyRelationship.spouse:
      case FamilyRelationship.exSpouse:
      case FamilyRelationship.brotherInLaw:
      case FamilyRelationship.sisterInLaw:
      case FamilyRelationship.cousin:
        return 0;
      case FamilyRelationship.son:
      case FamilyRelationship.daughter:
      case FamilyRelationship.stepSon:
      case FamilyRelationship.stepDaughter:
      case FamilyRelationship.adoptedSon:
      case FamilyRelationship.adoptedDaughter:
      case FamilyRelationship.sonInLaw:
      case FamilyRelationship.daughterInLaw:
      case FamilyRelationship.nephew:
      case FamilyRelationship.niece:
        return 1;
      case FamilyRelationship.grandson:
      case FamilyRelationship.granddaughter:
        return 2;
      case FamilyRelationship.greatGrandson:
      case FamilyRelationship.greatGranddaughter:
        return 3;
      case FamilyRelationship.other:
        return 0;
    }
  }

  /// Whether this is a spouse/partner relationship.
  bool get isSpouse =>
      this == FamilyRelationship.spouse || this == FamilyRelationship.exSpouse;

  /// Whether this is a parent relationship.
  bool get isParent =>
      this == FamilyRelationship.father ||
      this == FamilyRelationship.mother ||
      this == FamilyRelationship.stepfather ||
      this == FamilyRelationship.stepmother;

  /// Whether this is a child relationship.
  bool get isChild =>
      this == FamilyRelationship.son ||
      this == FamilyRelationship.daughter ||
      this == FamilyRelationship.stepSon ||
      this == FamilyRelationship.stepDaughter ||
      this == FamilyRelationship.adoptedSon ||
      this == FamilyRelationship.adoptedDaughter;

  /// Whether this is a sibling relationship.
  bool get isSibling =>
      this == FamilyRelationship.brother ||
      this == FamilyRelationship.sister ||
      this == FamilyRelationship.halfBrother ||
      this == FamilyRelationship.halfSister ||
      this == FamilyRelationship.stepBrother ||
      this == FamilyRelationship.stepSister;
}

/// Gender of a family member.
enum Gender {
  male,
  female,
  other,
  unknown,
}

/// Extension methods for [Gender].
extension GenderExtension on Gender {
  /// Get a human-readable label.
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.unknown:
        return 'Unknown';
    }
  }
}
