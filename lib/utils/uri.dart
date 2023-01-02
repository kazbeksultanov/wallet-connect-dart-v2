import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/sign/engine/types.dart';

// -- uri -------------------------------------------------- //

RelayerTypesProtocolOptions parseRelayParams({
  required Map<String, dynamic> params,
  String delimiter = "-",
}) {
  final Map<String, dynamic> relay = {};
  final prefix = "relay" + delimiter;
  params.keys.forEach((key) {
    if (key.startsWith(prefix)) {
      final name = key.replaceFirst(prefix, "");
      final value = params[key];
      relay[name] = value;
    }
  });
  return RelayerTypesProtocolOptions.fromJson(relay);
}

EngineTypesUriParameters parseUri(String str) {
  final uri = Uri.parse(str);
  final protocol = uri.scheme;
  final path = uri.path;
  final requiredValues = path.split("@");
  final queryParams = uri.queryParameters;
  final result = EngineTypesUriParameters(
    protocol: protocol,
    topic: requiredValues[0],
    version: int.parse(requiredValues[1]),
    symKey: queryParams['symKey']!,
    relay: parseRelayParams(params: queryParams),
  );
  return result;
}

Map<String, dynamic> formatRelayParams({
  required RelayerTypesProtocolOptions relay,
  String delimiter = "-",
}) {
  final prefix = "relay";
  final Map<String, dynamic> params = {};
  final relayObj = relay.toJson();
  relayObj.keys.forEach((key) {
    final k = prefix + delimiter + key;
    if (relayObj[key] != null) {
      params[k] = relayObj[key];
    }
  });
  return params;
}

String formatUri(EngineTypesUriParameters params) {
  return Uri(
    scheme: params.protocol,
    path: '${params.topic}@${params.version}',
    queryParameters: {
      'symKey': params.symKey,
      ...formatRelayParams(relay: params.relay),
    },
  ).toString();
}
