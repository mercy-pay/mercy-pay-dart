"""Generates lib/src/resources.dart from tool/operations.json and the API reference copy
(test/openapi.json). Run: python3 tool/generate.py"""
import json, os, re

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec = json.load(open(os.path.join(root, 'test/openapi.json')))
ops = json.load(open(os.path.join(root, 'tool/operations.json')))
catalog = json.load(open(os.path.join(root, 'test/catalog.json')))
shared_params = spec['components'].get('parameters', {})
definitions = {d['operationId']: d for methods in spec['paths'].values() for d in methods.values()}


def kind(prop):
    t = prop.get('type', 'object')
    t = [x for x in (t if isinstance(t, list) else [t]) if x != 'null'][0] if t else 'object'
    if prop.get('enum'):
        return ' | '.join("'" + e + "'" for e in prop['enum'] if e is not None)
    return {'string': 'String', 'integer': 'int', 'number': 'num', 'boolean': 'bool', 'array': 'List', 'object': 'Map'}.get(t, 'Object')


def documented_params(definition):
    """The keys an operation accepts, as doc comment lines."""
    lines = []
    for p in definition.get('parameters', []):
        p = shared_params[p['$ref'].split('/')[-1]] if '$ref' in p else p
        if p['in'] == 'query':
            name = p['name'][:-2] if p['name'].endswith('[]') else p['name']
            lines.append(f"  /// - `{name}` ({kind(p.get('schema', {}))})")
    body = definition.get('requestBody', {}).get('content', {}).get('application/json', {}).get('schema', {})
    required = set(body.get('required', []))
    for name, prop in body.get('properties', {}).items():
        lines.append(f"  /// - `{name}` ({kind(prop)}{', obligatoire' if name in required else ''})")
    return (['  ///', '  /// Paramètres :'] + lines) if lines else []
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
       "import 'client.dart';", "import 'errors.dart';", "import 'page.dart';", '',
       'abstract class _Resource {', '  _Resource(this._client);', '', '  final MercyPay _client;', '',
       '  Future<Map<String, dynamic>> _object(String method, String path, Map<String, Object?> params, [String? idempotencyKey]) async {',
       '    final body = await _client.request(method, path, params: params, idempotencyKey: idempotencyKey);',
       "    final data = body['data'];",
       '    return data is Map ? Map<String, dynamic>.from(data) : body;', '  }', '',
       '  Future<Page> _list(String path, Map<String, Object?> params) async {',
       "    final body = await _client.request('GET', path, params: params);",
       '    return Page(body, (next) => _list(path, next), params);', '  }', '',
       '  Future<Map<String, dynamic>> _poll(Future<Map<String, dynamic>> Function() read, List<String> finalStatuses, Duration timeout, Duration interval, String what) async {',
       '    final deadline = DateTime.now().add(timeout);',
       '    var delay = interval;',
       '    var current = await read();',
       "    while (!finalStatuses.contains(current['status'])) {",
       '      if (DateTime.now().add(delay).isAfter(deadline)) {',
       "        throw WaitTimeoutException(\"$what n'a pas atteint de statut final à temps (statut : ${current['status']}).\", current);",
       '      }',
       '      await _client.pause(delay);',
       '      final next = (delay.inMilliseconds * 1.5).round();',
       '      delay = Duration(milliseconds: next > 10000 ? 10000 : next);',
       '      current = await read();',
       '    }',
       '    return current;',
       '  }', '}', '']
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
        out += documented_params(definitions[o['operationId']])
        if is_list[o['operationId']]:
            out.append(f'  Future<Page> {method}({sig}) => _list({path}, params);')
        else:
            extra = ', idempotencyKey' if o['http'] == 'POST' else ''
            out.append(f"  Future<Map<String, dynamic>> {method}({sig}) => _object('{o['http']}', {path}, params{extra});")
        out.append('')
    extras = os.path.join(root, 'tool/extras', f'{cls}.dart')
    if os.path.exists(extras):
        out += open(extras).read().rstrip().split('\n')
        out.append('')
    out[-1] = '}'
    out.append('')
open(os.path.join(root, 'lib/src/resources.dart'), 'w').write('\n'.join(out))

countries = catalog['countries']
cat = ["// Généré par tool/generate.py depuis le catalogue Mercy Pay. Ne pas modifier à la main.", '',
       '/// The open countries, their mobile money operators and the webhook event types. A new',
       '/// operator may appear before this list knows it: any code stays accepted.',
       'abstract final class MercyPayCatalog {']
cat.append('  static const countries = <String, ({String name, String currency, Map<String, String> providers})>{')
for c in countries:
    providers = ', '.join(f"'{p['code']}': '{p['name']}'" for p in c['providers'])
    name = c['name'].replace("'", "\\'")
    cat.append(f"    '{c['code']}': (name: '{name}', currency: '{c['currency']}', providers: {{{providers}}}),")
cat.append('  };')
cat.append('')
cat.append('  static const eventTypes = <String>[' + ', '.join(f"'{t}'" for t in catalog['event_types']) + '];')
cat.append('')
for c in countries:
    for p in c['providers']:
        name = ''.join(part.capitalize() if i else part.lower() for i, part in enumerate(p['code'].split('_')))
        cat.append(f"  static const {name} = '{p['code']}';")
cat.append('}')
open(os.path.join(root, 'lib/src/catalog.dart'), 'w').write('\n'.join(cat) + '\n')
print(len(services), 'resources,', len(ops), 'operations')
