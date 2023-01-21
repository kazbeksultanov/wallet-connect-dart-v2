import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/sign/engine/models.dart';
import 'package:wallet_connect/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect/sign/sign-client/session/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';

part 'models.g.dart';

@JsonSerializable()
@HiveType(typeId: 16)
class RequestSessionRequest {
  @HiveField(0)
  final RequestArguments request;
  @HiveField(1)
  final String chainId;

  const RequestSessionRequest({
    required this.request,
    required this.chainId,
  });

  factory RequestSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSessionRequestToJson(this);
}

@JsonSerializable()
class RequestSessionEvent {
  final SessionEmitEvent event;
  final String chainId;

  const RequestSessionEvent({
    required this.event,
    required this.chainId,
  });

  factory RequestSessionEvent.fromJson(Map<String, dynamic> json) =>
      _$RequestSessionEventFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSessionEventToJson(this);
}

@JsonSerializable()
class RequestSessionUpdate {
  final SessionNamespaces namespaces;

  const RequestSessionUpdate({
    required this.namespaces,
  });

  factory RequestSessionUpdate.fromJson(Map<String, dynamic> json) =>
      _$RequestSessionUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSessionUpdateToJson(this);
}

@JsonSerializable()
class RequestSessionDelete {
  final int code;
  final String message;

  const RequestSessionDelete({
    required this.code,
    required this.message,
  });

  factory RequestSessionDelete.fromJson(Map<String, dynamic> json) =>
      _$RequestSessionDeleteFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSessionDeleteToJson(this);
}

@JsonSerializable()
class RequestSessionPropose {
  final List<RelayerProtocolOptions> relays;
  final ProposalRequiredNamespaces requiredNamespaces;
  final ProposalProposer proposer;

  RequestSessionPropose({
    required this.relays,
    required this.requiredNamespaces,
    required this.proposer,
  });

  factory RequestSessionPropose.fromJson(Map<String, dynamic> json) =>
      _$RequestSessionProposeFromJson(json);

  Map<String, dynamic> toJson() => _$RequestSessionProposeToJson(this);
}

typedef ResultPairingDelete = bool;
typedef ResultPairingPing = bool;

@JsonSerializable()
class ResultSessionPropose {
  final RelayerProtocolOptions relay;
  final String responderPublicKey;

  ResultSessionPropose({
    required this.relay,
    required this.responderPublicKey,
  });

  factory ResultSessionPropose.fromJson(Map<String, dynamic> json) =>
      _$ResultSessionProposeFromJson(json);

  Map<String, dynamic> toJson() => _$ResultSessionProposeToJson(this);
}

typedef ResultSessionSettle = bool;
typedef ResultSessionUpdate = bool;
typedef ResultSessionExtend = bool;
typedef ResultSessionDelete = bool;
typedef ResultSessionPing = bool;
typedef ResultSessionRequest = JsonRpcResult;
typedef ResultSessionEvent = bool;