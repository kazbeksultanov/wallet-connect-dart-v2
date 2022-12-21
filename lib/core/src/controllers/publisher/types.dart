import 'package:logger/logger.dart';
import 'package:wallet_connect/core/src/controllers/relayer/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class PublisherTypesParams {
  final String topic;
  final String message;
  final RelayerTypesPublishOptions opts;

  PublisherTypesParams({
    required this.topic,
    required this.message,
    required this.opts,
  });
}

abstract class IPublisher extends IEvents {
  String get name;
  IRelayer get relayer;
  Logger get logger;

  Future<void> publish({
    required String topic,
    required String message,
    RelayerTypesPublishOptions? opts,
  });
}
