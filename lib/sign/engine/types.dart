import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/sign/sign-client/client/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

part 'types.g.dart';

class EngineTypesUriParameters {
  final String protocol;
  final int version;
  final String topic;
  final String symKey;
  final RelayerTypesProtocolOptions relay;

  EngineTypesUriParameters({
    required this.protocol,
    required this.version,
    required this.topic,
    required this.symKey,
    required this.relay,
  });
}

@JsonSerializable()
class SessionSettleRequestParams {
  final RelayerTypesProtocolOptions relay;
  final SessionTypesPublicKeyMetadata controller;
  final SessionTypesNamespaces namespaces;
  final int expiry;

  SessionSettleRequestParams(
    this.relay,
    this.controller,
    this.namespaces,
    this.expiry,
  );

  factory SessionSettleRequestParams.fromJson(Map<String, dynamic> json) =>
      _$SessionSettleRequestParamsFromJson(json);
}

@JsonSerializable()
class SessionSettleParams {
  final RelayerTypesProtocolOptions relay;
  final SessionTypesPublicKeyMetadata controller;
  final SessionTypesNamespaces namespaces;
  final ProposalTypesRequiredNamespaces requiredNamespaces;
  final int expiry;

  SessionSettleParams({
    required this.relay,
    required this.controller,
    required this.namespaces,
    required this.requiredNamespaces,
    required this.expiry,
  });

  factory SessionSettleParams.fromJson(Map<String, dynamic> json) =>
      _$SessionSettleParamsFromJson(json);
}

@JsonSerializable()
class SessionConnectParams {
  final ProposalTypesRequiredNamespaces requiredNamespaces;
  final String? pairingTopic;
  final List<RelayerTypesProtocolOptions>? relays;

  SessionConnectParams({
    required this.requiredNamespaces,
    this.pairingTopic,
    this.relays,
  });

  factory SessionConnectParams.fromJson(Map<String, dynamic> json) =>
      _$SessionConnectParamsFromJson(json);
}

@JsonSerializable()
class SessionApproveParams {
  final int id;
  final SessionTypesNamespaces namespaces;
  final String? relayProtocol;

  SessionApproveParams({
    required this.id,
    required this.namespaces,
    this.relayProtocol,
  });

  factory SessionApproveParams.fromJson(Map<String, dynamic> json) =>
      _$SessionApproveParamsFromJson(json);
}

@JsonSerializable()
class SessionRejectParams {
  final int id;
  final ErrorResponse reason;

  SessionRejectParams({
    required this.id,
    required this.reason,
  });

  factory SessionRejectParams.fromJson(Map<String, dynamic> json) =>
      _$SessionRejectParamsFromJson(json);
}

@JsonSerializable()
class SessionUpdateParams {
  final String topic;
  final SessionTypesNamespaces namespaces;

  SessionUpdateParams({
    required this.topic,
    required this.namespaces,
  });

  factory SessionUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$SessionUpdateParamsFromJson(json);
}

class SessionRequestParams {
  final String topic;
  final RequestArguments request;
  final String chainId;

  SessionRequestParams({
    required this.topic,
    required this.request,
    required this.chainId,
  });
}

class SessionRespondParams {
  final String topic;
  final JsonRpcResponse response;

  SessionRespondParams({
    required this.topic,
    required this.response,
  });
}

class SessionEmitParams {
  final String topic;
  final SessionEmitEvent event;
  final String chainId;

  SessionEmitParams({
    required this.topic,
    required this.event,
    required this.chainId,
  });
}

@JsonSerializable()
class SessionEmitEvent {
  final String name;
  final dynamic data;

  const SessionEmitEvent({
    required this.name,
    required this.data,
  });

  factory SessionEmitEvent.fromJson(Map<String, dynamic> json) =>
      _$SessionEmitEventFromJson(json);
}

enum EngineTypesEvent {
  SESSION_CONNECT,
  SESSION_APPROVE,
  SESSION_UPDATE,
  SESSION_EXTEND,
  SESSION_PING,
  PAIRING_PING,
  SESSION_REQUEST,
}

extension EngineTypesEventExt on EngineTypesEvent {
  String get value {
    switch (this) {
      case EngineTypesEvent.SESSION_CONNECT:
        return "session_connect";
      case EngineTypesEvent.SESSION_APPROVE:
        return "session_approve";
      case EngineTypesEvent.SESSION_UPDATE:
        return "session_update";
      case EngineTypesEvent.SESSION_EXTEND:
        return "session_extend";
      case EngineTypesEvent.SESSION_PING:
        return "session_ping";
      case EngineTypesEvent.PAIRING_PING:
        return "pairing_ping";
      case EngineTypesEvent.SESSION_REQUEST:
        return "session_request";
      default:
        throw WCException('Invalid EngineTypesEvent');
    }
  }
}

enum JsonRpcMethod {
  WC_SESSION_PROPOSE,
  WC_SESSION_SETTLE,
  WC_SESSION_REQUEST,
  WC_SESSION_DELETE,
  WC_SESSION_PING,
  WC_SESSION_EVENT,
  WC_SESSION_UPDATE,
  WC_SESSION_EXTEND,
}

Map<JsonRpcMethod, String> _jsonRpcMethodMap = {
  JsonRpcMethod.WC_SESSION_PROPOSE: "wc_sessionPropose",
  JsonRpcMethod.WC_SESSION_SETTLE: "wc_sessionSettle",
  JsonRpcMethod.WC_SESSION_REQUEST: "wc_sessionRequest",
  JsonRpcMethod.WC_SESSION_DELETE: "wc_sessionDelete",
  JsonRpcMethod.WC_SESSION_PING: "wc_sessionPing",
  JsonRpcMethod.WC_SESSION_EVENT: "wc_sessionEvent",
  JsonRpcMethod.WC_SESSION_UPDATE: "wc_sessionUpdate",
  JsonRpcMethod.WC_SESSION_EXTEND: "wc_sessionExtend",
};

extension JsonRpcMethodExt on JsonRpcMethod {
  String get value {
    return _jsonRpcMethodMap[this]!;
  }
}

extension JsonRpcMethodExtStr on String {
  JsonRpcMethod get jsonRpcMethod {
    return _jsonRpcMethodMap.entries
        .where((element) => element.value == this)
        .first
        .key;
  }
}

class EngineTypesConnection {
  final String? uri;
  final dynamic approval;

  EngineTypesConnection({
    this.uri,
    this.approval,
  });
}

class EngineTypesApproved {
  final String topic;
  final bool acknowledged;

  EngineTypesApproved({
    required this.topic,
    required this.acknowledged,
  });
}

abstract class IEngine {
  ISignClient get client;

  Future<void> init();

  Future<EngineTypesConnection> connect(SessionConnectParams params);

  Future<PairingTypesStruct> pair(String uri);

//   public abstract approve(
//     params: ApproveParams,
//   ): Promise<{ topic: string; acknowledged: () => Promise<SessionTypes.Struct> }>;

//  Future<void> reject(params: RejectParams);

//   public abstract update(params: UpdateParams): AcknowledgedPromise;

//   public abstract extend(params: ExtendParams): AcknowledgedPromise;

//   public abstract request<T>(params: RequestParams): Promise<T>;

//  Future<void> respond(params: RespondParams);

//  Future<void> emit(params: EmitParams);

//  Future<void> ping(params: PingParams);

//  Future<void> disconnect(params: DisconnectParams);

//   public abstract find: (params: FindParams) => SessionTypes.Struct[];
}
