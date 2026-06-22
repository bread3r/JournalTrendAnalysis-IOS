# Journal Trend Analyzer

Flutter mobile app for PRM393 Lab 2. The app calls OpenAlex directly from the
mobile client and does not include a backend API, authentication, authorization,
or a database.

## Features

- Topic search for research articles from OpenAlex `/works`.
- Publication list with title, publication year, citation count, journal/source,
  and authors.
- Publication detail screen with authors, DOI, journal/source, citation count,
  OpenAlex link, publisher link, and abstract when available.
- Trend analysis chart grouped by `publication_year`.
- Top influential papers sorted by `cited_by_count:desc`.
- Top research journals using `group_by=primary_location.source.id`.
- Top contributing authors using `group_by=authorships.author.id`.
- Dashboard with total publications, average citations, most active year, top
  journal, top author, and most influential paper.

## Project Structure

```text
lib/
  models/      Data models for OpenAlex works and grouped results
  screens/     Search, detail, trend analysis, and dashboard screens
  services/    OpenAlex REST API integration
  state/       Provider-based app state
  utils/       Formatting helpers
  widgets/     Shared UI widgets
```

## Run

```bash
flutter pub get
flutter run -d <android-device-id>
```

OpenAlex can be called without a key for light development, but the current
documentation recommends an API key for normal usage. Pass it with:

```bash
flutter run -d <android-device-id> --dart-define=OPENALEX_API_KEY=your_key
```

## Verify

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

`flutter build apk --debug` requires a configured Android SDK and JDK 17.

## OpenAlex References

- API overview: https://developers.openalex.org/api-reference/introduction
- Works endpoint: https://developers.openalex.org/api-reference/works/list-works
- Search guide: https://developers.openalex.org/guides/searching
- Grouping guide: https://developers.openalex.org/guides/grouping

Kodus check for using AI check, automation of test project
