// ============================================================================
// File: connection_profile_parser.dart
// Description: Connection Profile Parser Utility
//
// Loads and parses the agent_info.json connection profile file to extract
// REL-ID credentials, host, and port information required for SDK initialization.
// ============================================================================

import 'dart:convert';
import 'package:flutter/services.dart';

/// Represents a single REL-ID entry from the connection profile
class RelId {
  final String name;
  final String relId;

  RelId({required this.name, required this.relId});

  factory RelId.fromJson(Map<String, dynamic> json) {
    return RelId(
      name: json['Name'] as String,
      relId: json['RelId'] as String,
    );
  }
}

/// Represents a single Profile entry with connection details
class Profile {
  final String name;
  final String host;
  final dynamic port; // Can be String or int from JSON

  Profile({required this.name, required this.host, required this.port});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['Name'] as String,
      host: json['Host'] as String,
      port: json['Port'], // Accept both String and int
    );
  }
}

/// Complete agent info structure from JSON file
class AgentInfo {
  final List<RelId> relIds;
  final List<Profile> profiles;

  AgentInfo({required this.relIds, required this.profiles});

  factory AgentInfo.fromJson(Map<String, dynamic> json) {
    return AgentInfo(
      relIds: (json['RelIds'] as List)
          .map((e) => RelId.fromJson(e as Map<String, dynamic>))
          .toList(),
      profiles: (json['Profiles'] as List)
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Parsed connection profile with extracted values
class ParsedAgentInfo {
  final String relId;
  final String host;
  final int port;

  ParsedAgentInfo({
    required this.relId,
    required this.host,
    required this.port,
  });
}

/// Parses agent info structure and extracts connection details
///
/// ## Parameters
/// - [profileData]: The complete agent info structure from JSON
///
/// ## Returns
/// Parsed connection profile with relId, host, and port
///
/// ## Throws
/// Exception if profile data is invalid or missing required fields
ParsedAgentInfo parseAgentInfo(AgentInfo profileData) {
  if (profileData.relIds.isEmpty) {
    throw Exception('No RelIds found in agent info');
  }

  if (profileData.profiles.isEmpty) {
    throw Exception('No Profiles found in agent info');
  }

  // Always pick the first array objects
  final firstRelId = profileData.relIds[0];

  if (firstRelId.name.isEmpty || firstRelId.relId.isEmpty) {
    throw Exception('Invalid RelId object - missing Name or RelId');
  }

  // Find matching profile by Name (1-1 mapping)
  final matchingProfile = profileData.profiles.firstWhere(
    (profile) => profile.name == firstRelId.name,
    orElse: () => throw Exception(
        'No matching profile found for RelId name: ${firstRelId.name}'),
  );

  if (matchingProfile.host.isEmpty || matchingProfile.port == null) {
    throw Exception('Invalid Profile object - missing Host or Port');
  }

  // Convert port to int if it's a String
  int port;
  if (matchingProfile.port is String) {
    port = int.tryParse(matchingProfile.port as String) ?? -1;
    if (port == -1) {
      throw Exception('Invalid port value: ${matchingProfile.port}');
    }
  } else {
    port = matchingProfile.port as int;
  }

  return ParsedAgentInfo(
    relId: firstRelId.relId,
    host: matchingProfile.host,
    port: port,
  );
}

/// Loads and parses the agent_info.json file from assets
///
/// ## Returns
/// Parsed connection profile with relId, host, and port
///
/// ## Throws
/// Exception if file cannot be loaded or parsed
///
/// ## Example
/// ```dart
/// try {
///   final profile = await loadAgentInfo();
///   print('Host: ${profile.host}:${profile.port}');
/// } catch (e) {
///   print('Failed to load agent info: $e');
/// }
/// ```
Future<ParsedAgentInfo> loadAgentInfo() async {
  try {
    final jsonString =
        await rootBundle.loadString('lib/uniken/cp/agent_info.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final profileData = AgentInfo.fromJson(jsonData);
    return parseAgentInfo(profileData);
  } catch (error) {
    throw Exception('Failed to load agent info: $error');
  }
}
