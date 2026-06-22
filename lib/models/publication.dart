class Publication {
  const Publication({
    required this.id,
    required this.title,
    required this.publicationYear,
    required this.citationCount,
    required this.journalName,
    required this.authors,
    this.doi,
    this.abstractText,
    this.landingPageUrl,
  });

  final String id;
  final String title;
  final int? publicationYear;
  final int citationCount;
  final String journalName;
  final List<String> authors;
  final String? doi;
  final String? abstractText;
  final String? landingPageUrl;

  String get yearLabel => publicationYear?.toString() ?? 'Unknown year';

  String get doiUrl {
    final value = doi?.trim();
    if (value == null || value.isEmpty) {
      return '';
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://doi.org/$value';
  }

  factory Publication.fromJson(Map<String, dynamic> json) {
    final primaryLocation = _asMap(json['primary_location']);
    final source = _asMap(primaryLocation?['source']);
    final ids = _asMap(json['ids']);

    return Publication(
      id: _clean(json['id']) ?? _clean(ids?['openalex']) ?? '',
      title:
          _clean(json['title']) ??
          _clean(json['display_name']) ??
          'Untitled publication',
      publicationYear: _asIntOrNull(json['publication_year']),
      citationCount: _asInt(json['cited_by_count']),
      journalName:
          _clean(source?['display_name']) ??
          _clean(primaryLocation?['raw_source_name']) ??
          'Unknown source',
      authors: _authorsFromJson(json['authorships']),
      doi: _clean(json['doi']) ?? _clean(ids?['doi']),
      abstractText: _abstractFromInvertedIndex(json['abstract_inverted_index']),
      landingPageUrl: _clean(primaryLocation?['landing_page_url']),
    );
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

  static int? _asIntOrNull(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static String? _clean(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static List<String> _authorsFromJson(Object? rawAuthorships) {
    final names = <String>{};

    if (rawAuthorships is List) {
      for (final authorship in rawAuthorships) {
        final map = _asMap(authorship);
        final author = _asMap(map?['author']);
        final name =
            _clean(author?['display_name']) ?? _clean(map?['raw_author_name']);

        if (name != null) {
          names.add(name);
        }
      }
    }

    return names.toList();
  }

  static String? _abstractFromInvertedIndex(Object? rawIndex) {
    final index = _asMap(rawIndex);
    if (index == null || index.isEmpty) {
      return null;
    }

    final wordsByPosition = <int, String>{};
    var maxPosition = -1;

    for (final entry in index.entries) {
      final positions = entry.value;
      if (positions is! List) {
        continue;
      }

      for (final position in positions) {
        final parsedPosition = _asIntOrNull(position);
        if (parsedPosition == null || parsedPosition < 0) {
          continue;
        }

        wordsByPosition[parsedPosition] = entry.key;
        if (parsedPosition > maxPosition) {
          maxPosition = parsedPosition;
        }
      }
    }

    if (maxPosition < 0) {
      return null;
    }

    final words = <String>[];
    for (var i = 0; i <= maxPosition; i++) {
      final word = wordsByPosition[i];
      if (word != null && word.isNotEmpty) {
        words.add(word);
      }
    }

    final text = words.join(' ');
    return text
        .replaceAllMapped(RegExp(r'\s+([,.;:?!])'), (match) => match[1]!)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
