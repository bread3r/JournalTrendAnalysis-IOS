import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/openalex_group.dart';
import '../models/publication.dart';
import '../models/research_analysis.dart';

class OpenAlexService {
  OpenAlexService({http.Client? client, this.apiKey})
    : _client = client ?? http.Client();

  static const _host = 'api.openalex.org';
  static const _worksPath = '/works';
  static const _articleFilter = 'type:article,is_retracted:false';
  static const _workFields =
      'id,doi,title,display_name,publication_year,cited_by_count,'
      'primary_location,authorships,abstract_inverted_index,ids';

  final http.Client _client;
  final String? apiKey;

  Future<ResearchAnalysis> analyzeTopic(String topic) async {
    final normalizedTopic = topic.trim();
    if (normalizedTopic.isEmpty) {
      throw const OpenAlexException('Please enter a research topic.');
    }

    final responses = await Future.wait([
      _fetchWorks(normalizedTopic, perPage: 50),
      _fetchWorks(normalizedTopic, perPage: 10, sort: 'cited_by_count:desc'),
      _fetchGroups(normalizedTopic, 'publication_year', perPage: 200),
      _fetchGroups(normalizedTopic, 'primary_location.source.id', perPage: 10),
      _fetchGroups(normalizedTopic, 'authorships.author.id', perPage: 10),
    ]);

    final searchResult = responses[0] as _WorksResponse;
    final topInfluential = responses[1] as _WorksResponse;
    final trendByYear = _prepareTrend(responses[2] as List<OpenAlexGroup>);
    final topJournals = responses[3] as List<OpenAlexGroup>;
    final topAuthors = responses[4] as List<OpenAlexGroup>;

    return ResearchAnalysis(
      topic: normalizedTopic,
      totalPublications: searchResult.totalCount,
      publications: searchResult.publications,
      topInfluential: topInfluential.publications,
      trendByYear: trendByYear,
      topJournals: topJournals,
      topAuthors: topAuthors,
    );
  }

  Future<_WorksResponse> _fetchWorks(
    String topic, {
    required int perPage,
    String? sort,
  }) async {
    final params = <String, String>{
      'search': topic,
      'filter': _articleFilter,
      'per_page': perPage.toString(),
      'select': _workFields,
    };
    if (sort != null) {
      params['sort'] = sort;
    }

    final json = await _getJson(_worksUri(params));

    final meta = _asMap(json['meta']);
    final results = json['results'];
    final publications = results is List
        ? results
              .whereType<Map>()
              .map(
                (item) => Publication.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
        : <Publication>[];

    return _WorksResponse(
      totalCount: _asInt(meta?['count']),
      publications: publications,
    );
  }

  Future<List<OpenAlexGroup>> _fetchGroups(
    String topic,
    String groupBy, {
    required int perPage,
  }) async {
    final json = await _getJson(
      _worksUri({
        'search': topic,
        'filter': _articleFilter,
        'group_by': groupBy,
        'per_page': perPage.toString(),
      }),
    );

    final groups = json['group_by'];
    if (groups is! List) {
      return const <OpenAlexGroup>[];
    }

    return groups
        .whereType<Map>()
        .map(
          (item) => OpenAlexGroup.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((group) => group.name.trim().isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    late http.Response response;

    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const OpenAlexException(
        'OpenAlex did not respond in time. Please try again.',
      );
    } on Object catch (error) {
      throw OpenAlexException('Network error: $error');
    }

    final body = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? decoded['message']?.toString()
          : 'OpenAlex request failed.';
      throw OpenAlexException(
        message ?? 'OpenAlex request failed (${response.statusCode}).',
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    throw const OpenAlexException('OpenAlex returned an unexpected response.');
  }

  Uri _worksUri(Map<String, String> params) {
    final query = <String, String>{
      ...params,
      if (apiKey != null && apiKey!.trim().isNotEmpty) 'api_key': apiKey!,
    };

    return Uri.https(_host, _worksPath, query);
  }

  List<OpenAlexGroup> _prepareTrend(List<OpenAlexGroup> rawGroups) {
    final currentYear = DateTime.now().year;
    final groups = rawGroups.where((group) {
      final year = group.year;
      return year != null && year <= currentYear;
    }).toList()..sort((a, b) => a.year!.compareTo(b.year!));

    return groups;
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class OpenAlexException implements Exception {
  const OpenAlexException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _WorksResponse {
  const _WorksResponse({required this.totalCount, required this.publications});

  final int totalCount;
  final List<Publication> publications;
}
