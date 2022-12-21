import 'package:logger/logger.dart';
import 'package:wallet_connect/core/src/controllers/core/types.dart';
import 'package:wallet_connect/core/src/controllers/publisher/types.dart';
import 'package:wallet_connect/core/src/controllers/subscriber/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/provider/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class RelayerTypesProtocolOptions {
  final String protocol;
  final String? data;

  RelayerTypesProtocolOptions({
    required this.protocol,
    this.data,
  });
}

class RelayerTypesPublishOptions {
  final RelayerTypesProtocolOptions? relay;
  final int? ttl;
  final bool? prompt;
  final int? tag;

  RelayerTypesPublishOptions({
    this.relay,
    this.ttl,
    this.prompt,
    this.tag,
  });
}

class RelayerTypesSubscribeOptions {
  final RelayerTypesProtocolOptions relay;

  RelayerTypesSubscribeOptions({required this.relay});
}

class RelayerTypesUnsubscribeOptions {
  final String? id;
  final RelayerTypesProtocolOptions relay;

  RelayerTypesUnsubscribeOptions({
    required this.id,
    required this.relay,
  });
}

class RelayerTypesMessageEvent {
  final String topic;
  final String message;

  RelayerTypesMessageEvent({
    required this.topic,
    required this.message,
  });
}

// class RelayerTypesRpcUrlParams {
//   final String protocol;
//   final int version;
//   final String auth;
//   final String relayUrl;
//   final String sdkVersion;
//   final String? projectId;

//   RelayerTypesRpcUrlParams({
//     required this.protocol,
//     required this.version,
//     required this.auth,
//     required this.relayUrl,
//     required this.sdkVersion,
//     this.projectId,
//   });
// }

class RelayerClientMetadata {
  final String protocol;
  final int version;
  final String env;
  final String? host;

  RelayerClientMetadata({
    required this.protocol,
    required this.version,
    required this.env,
    this.host,
  });
}

abstract class IRelayer with IEvents {
  ICore get core;

  Logger? get logger;

  String? get relayUrl;

  String? get projectId;

  ISubscriber get subscriber;

  IPublisher get publisher;

  // IMessageTracker get messages;

  IJsonRpcProvider get provider;

  String get name;

  bool get transportExplicitlyClosed;

  bool get connected;

  bool get connecting;

  Future<void> init();

  Future<void> publish({
    required String topic,
    required String message,
    RelayerTypesPublishOptions? opts,
  });

  Future<String> subscribe({
    required String topic,
    RelayerTypesSubscribeOptions? opts,
  });

  Future<void> unsubscribe({
    required String topic,
    RelayerTypesUnsubscribeOptions? opts,
  });
  Future<void> transportClose();
  Future<void> transportOpen({String? relayUrl});
}
