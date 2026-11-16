/// One page of a list, newest first. [data] is this page; [autoPaging] goes through every
/// page, fetched as you go.
class Page {
  Page(Map<String, dynamic> body, this._fetch, this._params)
      : data = [
          for (final row in body['data'] is List ? body['data'] as List : const [])
            if (row is Map) Map<String, dynamic>.from(row),
        ],
        hasMore = body['has_more'] == true,
        nextCursor = body['next_cursor'] as String?;

  final List<Map<String, dynamic>> data;
  final bool hasMore;
  final String? nextCursor;
  final Future<Page> Function(Map<String, Object?> params) _fetch;
  final Map<String, Object?> _params;

  Future<Page?> nextPage() async {
    if (!hasMore || nextCursor == null) return null;
    final params = Map<String, Object?>.of(_params)..remove('ending_before');
    return _fetch({...params, 'starting_after': nextCursor});
  }

  Stream<Map<String, dynamic>> autoPaging() async* {
    Page? page = this;
    while (page != null) {
      yield* Stream.fromIterable(page.data);
      page = await page.nextPage();
    }
  }
}
