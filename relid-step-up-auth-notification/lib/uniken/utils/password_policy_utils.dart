// ============================================================================
// File: password_policy_utils.dart
// Description: Password Policy Utilities
//
// Transformed from: passwordPolicyUtils.ts
// Provides functions for parsing and generating user-friendly password policy messages
// ============================================================================

import 'dart:convert';

/// Password Policy Data Class
///
/// Defines the structure of password policy data from REL-ID SDK
class PasswordPolicy {
  final int minL; // minimum length
  final int maxL; // maximum length
  final int minDg; // minimum digits
  final int minUc; // minimum uppercase letters
  final int minLc; // minimum lowercase letters
  final int minSc; // minimum special characters
  final String charsNotAllowed; // characters that are not allowed
  final int repetition; // max allowed repeated characters
  final bool userIDcheck; // whether User ID should not be included
  final String seqCheck; // disallow sequential characters
  final String blackListedCommonPassword; // if it should not be a common password
  final String? msg; // optional message from server
  final bool? sdkValidation; // SDK validation flag

  PasswordPolicy({
    required this.minL,
    required this.maxL,
    required this.minDg,
    required this.minUc,
    required this.minLc,
    required this.minSc,
    required this.charsNotAllowed,
    required this.repetition,
    required this.userIDcheck,
    required this.seqCheck,
    required this.blackListedCommonPassword,
    this.msg,
    this.sdkValidation,
  });

  factory PasswordPolicy.fromJson(Map<String, dynamic> json) {
    return PasswordPolicy(
      minL: json['minL'] ?? 0,
      maxL: json['maxL'] ?? 0,
      minDg: json['minDg'] ?? 0,
      minUc: json['minUc'] ?? 0,
      minLc: json['minLc'] ?? 0,
      minSc: json['minSc'] ?? 0,
      charsNotAllowed: json['charsNotAllowed'] ?? '',
      repetition: json['Repetition'] ?? 0,
      userIDcheck: json['UserIDcheck'] ?? false,
      seqCheck: json['SeqCheck'] ?? '',
      blackListedCommonPassword: json['BlackListedCommonPassword'] ?? '',
      msg: json['msg'],
      sdkValidation: json['SDKValidation'],
    );
  }
}

/// Generates a user-friendly password policy message
///
/// ## Parameters
/// - [policy]: The parsed password policy object
///
/// ## Returns
/// A user-friendly message describing the password requirements
String generatePasswordPolicyMessage(PasswordPolicy policy) {
  // Check if there's a valid message from the server
  if (policy.msg != null &&
      policy.msg!.trim().isNotEmpty &&
      policy.msg != 'Invalid password policy') {
    return policy.msg!;
  }

  // Generate user-friendly message from policy fields
  final requirements = <String>[];

  // Length requirements
  if (policy.minL > 0 && policy.maxL > 0) {
    if (policy.minL == policy.maxL) {
      requirements.add('Must be exactly ${policy.minL} characters long');
    } else {
      requirements.add('Must be between ${policy.minL} and ${policy.maxL} characters long');
    }
  } else if (policy.minL > 0) {
    requirements.add('Must be at least ${policy.minL} characters long');
  } else if (policy.maxL > 0) {
    requirements.add('Must be no more than ${policy.maxL} characters long');
  }

  // Character type requirements
  if (policy.minDg > 0) {
    requirements.add('Must contain at least ${policy.minDg} digit${policy.minDg > 1 ? 's' : ''}');
  }

  if (policy.minUc > 0) {
    requirements.add('Must contain at least ${policy.minUc} uppercase letter${policy.minUc > 1 ? 's' : ''}');
  }

  if (policy.minLc > 0) {
    requirements.add('Must contain at least ${policy.minLc} lowercase letter${policy.minLc > 1 ? 's' : ''}');
  }

  if (policy.minSc > 0) {
    requirements.add('Must contain at least ${policy.minSc} special character${policy.minSc > 1 ? 's' : ''}');
  }

  // Restrictions
  if (policy.charsNotAllowed.trim().isNotEmpty) {
    requirements.add('Cannot contain these characters: ${policy.charsNotAllowed}');
  }

  if (policy.repetition > 0) {
    requirements.add('Cannot have more than ${policy.repetition} repeated characters in a row');
  }

  if (policy.userIDcheck) {
    requirements.add('Cannot contain your username');
  }

  if (policy.seqCheck.toLowerCase() == 'true') {
    requirements.add('Cannot contain sequential characters (e.g., 123, abc)');
  }

  if (policy.blackListedCommonPassword.toLowerCase() == 'true') {
    requirements.add('Cannot be a commonly used password');
  }

  // If no requirements found, return a generic message
  if (requirements.isEmpty) {
    return 'Please enter a secure password';
  }

  // Format the requirements into a readable message
  if (requirements.length == 1) {
    return requirements[0];
  } else if (requirements.length == 2) {
    return '${requirements[0]} and ${requirements[1].toLowerCase()}';
  } else {
    final lastRequirement = requirements.removeLast();
    return '${requirements.join(', ')}, and ${lastRequirement.toLowerCase()}';
  }
}

/// Parses a password policy JSON string and generates a user-friendly message
///
/// ## Parameters
/// - [policyJsonString]: The JSON string containing password policy data
///
/// ## Returns
/// A user-friendly password policy message, or error message if parsing fails
///
/// ## Example
/// ```dart
/// final policy = parseAndGeneratePolicyMessage(policyJson);
/// print(policy); // "Must be at least 8 characters long and contain at least 1 uppercase letter"
/// ```
String parseAndGeneratePolicyMessage(String policyJsonString) {
  try {
    final policyMap = json.decode(policyJsonString) as Map<String, dynamic>;
    final policy = PasswordPolicy.fromJson(policyMap);
    return generatePasswordPolicyMessage(policy);
  } catch (error) {
    print('Failed to parse password policy JSON: $error');
    return 'Please enter a secure password according to your organization\'s policy';
  }
}

/// Extracts a challenge value from RDNAChallengeResponse by key
///
/// ## Parameters
/// - [challengeInfo]: List of challenge info key-value pairs
/// - [key]: The key to search for (e.g., 'RELID_PASSWORD_POLICY')
///
/// ## Returns
/// The value for the given key, or null if not found
String? getChallengeValue(List<dynamic>? challengeInfo, String key) {
  if (challengeInfo == null) return null;

  for (final item in challengeInfo) {
    if (item is Map<String, dynamic>) {
      if (item['key'] == key) {
        return item['value'] as String?;
      }
    }
  }

  return null;
}
