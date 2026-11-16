"""Generates lib/src/resources.dart from tool/operations.json and the API reference copy
(test/openapi.json). Run: python3 tool/generate.py"""
import json, os, re

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec = json.load(open(os.path.join(root, 'test/openapi.json')))
ops = json.load(open(os.path.join(root, 'tool/operations.json')))
summary, is_list = {}, {}
for path, methods in spec['paths'].items():
    for verb, d in methods.items():
        ok = next((r for s, r in d['responses'].items() if s.startswith('2')), {})
        schema = ok.get('content', {}).get('application/json', {}).get('schema', {})
        summary[d['operationId']] = d.get('summary', '')
        is_list[d['operationId']] = schema.get('properties', {}).get('object', {}).get('const') == 'list' or schema.get('properties', {}).get('data', {}).get('type') == 'array'

def plural(s):
    return s if s in ('Account', 'ProviderStatus', 'BillingPortal') else s + 's'

def camel(s):
    return s[0].lower() + s[1:]

out = ["// Généré par tool/generate.py depuis la référence de l'API. Ne pas modifier à la main.", '',
       "import 'client.dart';", "import 'page.dart';", '',
       'abstract class _Resource {', '  _Resource(this._client);', '', '  final MercyPay _client;', '',
       '  Future<Map<String, dynamic>> _object(String method, String path, Map<String, Object?> params, [String? idempotencyKey]) async {',
       '    final body = await _client.request(method, path, params: params, idempotencyKey: idempotencyKey);',
       "    final data = body['data'];",
       '    return data is Map ? Map<String, dynamic>.from(data) : body;', '  }', '',
       '  Future<Page> _list(String path, Map<String, Object?> params) async {',
       "    final body = await _client.request('GET', path, params: params);",
       '    return Page(body, (next) => _list(path, next), params);', '  }', '}', '']
services = {}
for o in ops:
    services.setdefault(o['service'], []).append(o)
for service, items in services.items():
    cls = plural(service) + 'Resource'
    out += [f'class {cls} extends _Resource {{', f'  {cls}(super.client);', '']
    for o in items:
        method = 'list' if o['method'] == 'all' else o['method']
        ids = [camel(i) for i in o['ids']]
        path = "'" + re.sub(r'\{\}', lambda m, it=iter(ids): '${Uri.encodeComponent(' + next(it) + ')}', o['path']) + "'"
        args = [f'String {i}' for i in ids] + ['[Map<String, Object?> params = const {}]']
        named = ''
        if o['http'] == 'POST':
            args[-1] = 'Map<String, Object?> params = const {}'
            named = 'String? idempotencyKey'
        sig = ', '.join(a for a in args if not a.startswith('[')) 
        if o['http'] == 'POST':
            sig = ', '.join([f'String {i}' for i in ids] + ['{' + 'Map<String, Object?> params = const {}, String? idempotencyKey' + '}'])
        else:
            sig = ', '.join([f'String {i}' for i in ids] + ['[Map<String, Object?> params = const {}]'])
        out.append(f'  /// {summary[o["operationId"]]}. {o["http"]} /api/v1/{o["path"].replace("{}", "{id}")}')
        if is_list[o['operationId']]:
            out.append(f'  Future<Page> {method}({sig}) => _list({path}, params);')
        else:
            extra = ', idempotencyKey' if o['http'] == 'POST' else ''
            out.append(f"  Future<Map<String, dynamic>> {method}({sig}) => _object('{o['http']}', {path}, params{extra});")
        out.append('')
    out[-1] = '}'
    out.append('')
open(os.path.join(root, 'lib/src/resources.dart'), 'w').write('\n'.join(out))
print(len(services), 'resources,', len(ops), 'operations')
