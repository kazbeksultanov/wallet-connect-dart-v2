// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RpcSessionRequestParamsAdapter
    extends TypeAdapter<RpcSessionRequestParams> {
  @override
  final int typeId = 16;

  @override
  RpcSessionRequestParams read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RpcSessionRequestParams(
      request: fields[0] as RequestArguments<dynamic>,
      chainId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RpcSessionRequestParams obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.request)
      ..writeByte(1)
      ..write(obj.chainId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RpcSessionRequestParamsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcSessionRequestParams _$RpcSessionRequestParamsFromJson(
        Map<String, dynamic> json) =>
    RpcSessionRequestParams(
      request: RequestArguments<dynamic>.fromJson(
          json['request'] as Map<String, dynamic>, (value) => value),
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$RpcSessionRequestParamsToJson(
        RpcSessionRequestParams instance) =>
    <String, dynamic>{
      'request': instance.request.toJson(),
      'chainId': instance.chainId,
    };

RpcSessionEventParams _$RpcSessionEventParamsFromJson(
        Map<String, dynamic> json) =>
    RpcSessionEventParams(
      event: SessionEmitEvent.fromJson(json['event'] as Map<String, dynamic>),
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$RpcSessionEventParamsToJson(
        RpcSessionEventParams instance) =>
    <String, dynamic>{
      'event': instance.event.toJson(),
      'chainId': instance.chainId,
    };

RpcSessionUpdateParams _$RpcSessionUpdateParamsFromJson(
        Map<String, dynamic> json) =>
    RpcSessionUpdateParams(
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SessionNamespace.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$RpcSessionUpdateParamsToJson(
        RpcSessionUpdateParams instance) =>
    <String, dynamic>{
      'namespaces': instance.namespaces.map((k, e) => MapEntry(k, e.toJson())),
    };

RpcSessionProposeParams _$RpcSessionProposeParamsFromJson(
        Map<String, dynamic> json) =>
    RpcSessionProposeParams(
      relays: (json['relays'] as List<dynamic>)
          .map(
              (e) => RelayerProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ProposalRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      proposer:
          ProposalProposer.fromJson(json['proposer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RpcSessionProposeParamsToJson(
        RpcSessionProposeParams instance) =>
    <String, dynamic>{
      'relays': instance.relays.map((e) => e.toJson()).toList(),
      'requiredNamespaces':
          instance.requiredNamespaces.map((k, e) => MapEntry(k, e.toJson())),
      'proposer': instance.proposer.toJson(),
    };

ResultSessionPropose _$ResultSessionProposeFromJson(
        Map<String, dynamic> json) =>
    ResultSessionPropose(
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      responderPublicKey: json['responderPublicKey'] as String,
    );

Map<String, dynamic> _$ResultSessionProposeToJson(
        ResultSessionPropose instance) =>
    <String, dynamic>{
      'relay': instance.relay.toJson(),
      'responderPublicKey': instance.responderPublicKey,
    };
