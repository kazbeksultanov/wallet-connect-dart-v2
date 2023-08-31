import 'dart:async';

import 'package:test/test.dart';
import 'package:wallet_connect_dart_v2/utils/uri.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/logger/logger.dart';

import 'mock_data.dart';

void main() {
  setUp(() async {});

  group("Sign Client Integration", () {
    // test("init", () async {
    //   final client = await SignClient.init(
    //     name: "init",
    //     logLevel: Level.debug,
    //     relayUrl: TEST_RELAY_URL,
    //     projectId: TEST_PROJECT_ID,
    //     database: ":memory:",
    //   );
    // });

    group("connect", () {
      test("connect (with new pairing)", () async {
        final clients = await initTwoClients();

        await testConnectMethod(
          clientA: clients.clientA,
          clientB: clients.clientB,
          // qrCodeScanLatencyMs: 5000,
        );

        await disconnectClients([clients.clientA, clients.clientB]);
      });
      test("connect (with old pairing)", () async {
        final clients = await initTwoClients();

        final connection = await testConnectMethod(
          clientA: clients.clientA,
          clientB: clients.clientB,
        );

        expect(
            clients.clientA.pairing.keys, equals(clients.clientB.pairing.keys));

        await testConnectMethod(
          clientA: clients.clientA,
          clientB: clients.clientB,
          pairingTopic: connection.pairingA.topic,
        );
        await disconnectClients([clients.clientA, clients.clientB]);
      });
    });

    group("disconnect", () {
      group("pairing", () {
        test("deletes the pairing on disconnect", () async {
          final clients = await initTwoClients();
          final connection = await testConnectMethod(
            clientA: clients.clientA,
            clientB: clients.clientB,
          );
          final topic = connection.pairingA.topic;
          final reason = getSdkError(SdkErrorKey.USER_DISCONNECTED);
          await clients.clientA.disconnect(topic: topic, reason: reason);
          expect(() => clients.clientA.pairing.get(topic),
              throwsA(WCException('No matching key. pairing: $topic')));
          expect(
            () => clients.clientA.ping(topic),
            throwsA(WCException(
                'No matching key. session or pairing topic doesn\'t exist: $topic')),
          );
          await disconnectClients([clients.clientA, clients.clientB]);
        });
      });

      group("session", () {
        test("deletes the session on disconnect", () async {
          final clients = await initTwoClients();
          final connection = await testConnectMethod(
            clientA: clients.clientA,
            clientB: clients.clientB,
          );
          final topic = connection.sessionA.topic;
          final reason = getSdkError(SdkErrorKey.USER_DISCONNECTED);
          await clients.clientA.disconnect(topic: topic, reason: reason);
          expect(() => clients.clientA.session.get(topic),
              throwsA(WCException('No matching key. session: $topic')));
          expect(
            () => clients.clientA.ping(topic),
            throwsA(WCException(
                'No matching key. session or pairing topic doesn\'t exist: $topic')),
          );
          await disconnectClients([clients.clientA, clients.clientB]);
        });
      });
    });

    group("ping", () {
      test("throws if the topic is not a known pairing or session topic",
          () async {
        final clients = await initTwoClients();
        const fakeTopic = "nonsense";
        expect(
            () => clients.clientA.ping(fakeTopic),
            throwsA(WCException(
              'No matching key. session or pairing topic doesn\'t exist: $fakeTopic',
            )));
        await disconnectClients([clients.clientA, clients.clientB]);
      });
      group("pairing", () {
        group("with existing pairing", () {
          test("A pings B", () async {
            final clients = await initTwoClients();
            final connection = await testConnectMethod(
              clientA: clients.clientA,
              clientB: clients.clientB,
            );
            final topic = connection.pairingA.topic;
            await clients.clientA.ping(topic);
            await disconnectClients([clients.clientA, clients.clientB]);
          });
          test("B pings A", () async {
            final clients = await initTwoClients();
            final connection = await testConnectMethod(
              clientA: clients.clientA,
              clientB: clients.clientB,
            );
            final topic = connection.pairingA.topic;
            await clients.clientB.ping(topic);
            await disconnectClients([clients.clientA, clients.clientB]);
          });
        });
      });
      group("session", () {
        group("with existing session", () {
          test("A pings B", () async {
            final clients = await initTwoClients();
            final connection = await testConnectMethod(
              clientA: clients.clientA,
              clientB: clients.clientB,
            );
            final topic = connection.sessionA.topic;
            await clients.clientA.ping(topic);
            await disconnectClients([clients.clientA, clients.clientB]);
          });
          test("B pings A", () async {
            final clients = await initTwoClients();
            final connection = await testConnectMethod(
              clientA: clients.clientA,
              clientB: clients.clientB,
            );
            final topic = connection.sessionA.topic;
            await clients.clientB.ping(topic);
            await disconnectClients([clients.clientA, clients.clientB]);
          });
          test("can get pending session request", () async {
            final clients = await initTwoClients();
            final connection = await testConnectMethod(
              clientA: clients.clientA,
              clientB: clients.clientB,
            );
            final topic = connection.sessionA.topic;

            late JsonRpcError rejection;

            await Future.wait([
              Future.sync(() {
                final completer = Completer<void>();
                clients.clientB.on("session_request", (event) async {
                  final pendingRequests =
                      clients.clientB.pendingRequest.getAll();
                  final params = pendingRequests[0].params;
                  final topic = pendingRequests[0].topic;
                  final id = pendingRequests[0].id;
                  final args =
                      event as SignClientEventParams<RequestSessionRequest>;
                  expect(params.toJson(), equals(args.params!.toJson()));
                  expect(topic, equals(args.topic));
                  expect(id, equals(args.id));
                  rejection = formatJsonRpcError(
                    id: id,
                    error:
                        getSdkError(SdkErrorKey.USER_REJECTED_METHODS).message,
                  );
                  await clients.clientB.respond(SessionRespondParams(
                    topic: topic,
                    response: rejection,
                  ));
                  completer.complete();
                });
                return completer.future;
              }),
              Future.sync(() async {
                try {
                  await clients.clientA.request<Object?>(SessionRequestParams(
                    topic: topic,
                    request:
                        RequestArguments(method: TEST_METHODS[0], params: []),
                    chainId: TEST_CHAINS[0],
                  ));
                } on ErrorResponse catch (err) {
                  expect(err.message, equals(rejection.error!.message));
                }
              }),
            ]);
            await disconnectClients([clients.clientA, clients.clientB]);
          });
        });
      });
    });

    group("update", () {
      test("updates session namespaces state with provided namespaces",
          () async {
        final clients = await initTwoClients();
        final connection = await testConnectMethod(
          clientA: clients.clientA,
          clientB: clients.clientB,
        );
        final topic = connection.sessionA.topic;
        final namespacesBefore = clients.clientA.session.get(topic).namespaces;
        final namespacesAfter = {
          ...namespacesBefore,
          'eip9001': const SessionNamespace(
            accounts: ["eip9001:1:0x000000000000000000000000000000000000dead"],
            methods: ["eth_sendTransaction"],
            events: ["accountsChanged"],
          ),
        };
        final update = await clients.clientA.update(SessionUpdateParams(
          topic: topic,
          namespaces: namespacesAfter,
        ));
        await update.acknowledged;
        final result = clients.clientA.session.get(topic).namespaces;
        expect(result, equals(namespacesAfter));
        await disconnectClients([clients.clientA, clients.clientB]);
      });
    });

    group("extend", () {
      test("updates session expiry state", () async {
        final clients = await initTwoClients();
        final connection = await testConnectMethod(
          clientA: clients.clientA,
          clientB: clients.clientB,
        );
        final topic = connection.sessionA.topic;
        final prevExpiry = clients.clientA.session.get(topic).expiry;
        // vi.useFakeTimers();
        // Fast-forward system time by 60 seconds after expiry was first set.
        // vi.setSystemTime(Date.now() + 60_000);
        await Future.delayed(const Duration(milliseconds: 1000));
        final extend = await clients.clientA.extend(topic);
        await extend.acknowledged;
        final updatedExpiry = clients.clientA.session.get(topic).expiry;
        expect(updatedExpiry, greaterThan(prevExpiry));
        // vi.useRealTimers();
        await disconnectClients([clients.clientA, clients.clientB]);
      });
    });

    // group("namespaces", () {
    //   test("should pair with empty namespaces", () async {
    //     final clients = await initTwoClients();
    //     final ProposalTypesRequiredNamespaces requiredNamespaces = {};
    //     final connection = await testConnectMethod(
    //       clientA: clients.clientA,
    //       clientB: clients.clientB,
    //       requiredNamespaces: requiredNamespaces,
    //       namespaces: TEST_NAMESPACES,
    //     );
    //     final sessionA = connection.sessionA;
    //     expect(requiredNamespaces, equals({}));
    //     // requiredNamespaces are built internally from the namespaces during approve()
    //     expect(sessionA.requiredNamespaces, equals(TEST_REQUIRED_NAMESPACES));
    //     expect(
    //       sessionA.requiredNamespaces,
    //       equals(
    //           clients.clientB.session.get(sessionA.topic).requiredNamespaces),
    //     );
    //     await disconnectClients([clients.clientA, clients.clientB]);
    //   });
    // });
  });
}

class Clients {
  final SignClient clientA;
  final SignClient clientB;

  Clients({
    required this.clientA,
    required this.clientB,
  });
}

Future<Clients> initTwoClients() async {
  final logger = Logger(
    printer: PrefixPrinter(PrettyPrinter(colors: false)),
    level: Level.debug,
  );

  final clientA = await SignClient.init(
    name: "clientA",
    logger: logger,
    relayUrl: TEST_RELAY_URL,
    projectId: TEST_PROJECT_ID,
    database: ":memory:",
    metadata: TEST_APP_METADATA_A,
  );

  final clientB = await SignClient.init(
    name: "clientB",
    logger: logger,
    relayUrl: TEST_RELAY_URL,
    projectId: TEST_PROJECT_ID,
    database: ":memory:",
    metadata: TEST_APP_METADATA_B,
  );

  return Clients(
    clientA: clientA,
    clientB: clientB,
  );
}

Future<void> disconnectClients(List<SignClient> clients) async {
  for (final client in clients) {
    if (client.core.relayer.connected) {
      await client.core.relayer.transportClose();
    }
  }
}

class Connection {
  final PairingStruct pairingA;
  final SessionStruct sessionA;
  final int? clientAConnectLatencyMs, settlePairingLatencyMs;

  Connection({
    required this.pairingA,
    required this.sessionA,
    this.clientAConnectLatencyMs,
    this.settlePairingLatencyMs,
  });
}

Future<Connection> testConnectMethod({
  required SignClient clientA,
  required SignClient clientB,
  String? pairingTopic,
  ProposalRequiredNamespaces? requiredNamespaces,
  SessionNamespaces? namespaces,
  int? qrCodeScanLatencyMs,
}) async {
  final start = DateTime.now().millisecondsSinceEpoch;

  requiredNamespaces ??= TEST_REQUIRED_NAMESPACES;
  namespaces ??= TEST_NAMESPACES;

  SessionStruct? sessionA, sessionB;

  final resolveSessionProposal = Completer<void>();
  clientB.once(SignClientEvent.SESSION_PROPOSAL.value, (event) async {
    final evventData = event as SignClientEventParams<RequestSessionPropose>;

    expect(evventData.params!.requiredNamespaces, equals(requiredNamespaces));

    final approval = await clientB.approve(SessionApproveParams(
      id: evventData.id!,
      namespaces: namespaces!,
    ));

    sessionB ??= await approval.acknowledged;

    resolveSessionProposal.complete();
  });

  final conn = await clientA.connect(SessionConnectParams(
    requiredNamespaces: requiredNamespaces,
    optionalNamespaces: {},
    pairingTopic: pairingTopic,
  ));
  final clientAConnectLatencyMs = DateTime.now().millisecondsSinceEpoch - start;

  PairingStruct? pairingA, pairingB;

  if (pairingTopic == null) {
    if (qrCodeScanLatencyMs != null) {
      await Future.delayed(Duration(milliseconds: qrCodeScanLatencyMs));
    }
    final uriParams = parseUri(conn.uri!);
    pairingA = clientA.pairing.get(uriParams.topic);
    expect(pairingA.topic, equals(uriParams.topic));
    expect(pairingA.relay, equals(uriParams.relay));
  } else {
    pairingA = clientA.pairing.get(pairingTopic);
    pairingB = clientB.pairing.get(pairingTopic);
  }

  final futures = await Future.wait<dynamic>([
    resolveSessionProposal.future,
    Future.sync(() async {
      if (pairingTopic == null) {
        pairingB = await clientB.pair(conn.uri!);

        expect(pairingB!.topic, equals(pairingA!.topic));
        expect(pairingB!.relay, equals(pairingA.relay));
      }
    }),
    conn.approval!,
  ]);

  final settlePairingLatencyMs = DateTime.now().millisecondsSinceEpoch -
      start -
      (qrCodeScanLatencyMs ?? 0);

  sessionA = futures[2];

  // topic
  expect(sessionA!.topic, equals(sessionB!.topic));
  // relay
  expect(sessionA.relay, equals(TEST_RELAY_OPTIONS));
  expect(sessionA.relay, equals(sessionB!.relay));
  // namespaces
  expect(sessionA.namespaces, equals(namespaces));
  expect(sessionA.namespaces, equals(sessionB!.namespaces));
  // expiry
  expect(sessionA.expiry - sessionB!.expiry, lessThan(5));
  // acknowledged
  expect(sessionA.acknowledged, equals(sessionB!.acknowledged));
  // participants
  expect(sessionA.self, equals(sessionB!.peer));
  expect(sessionA.peer, equals(sessionB!.self));
  // controller
  expect(sessionA.controller, equals(sessionB!.controller));
  expect(sessionA.controller, equals(sessionA.peer.publicKey));
  expect(sessionB!.controller, equals(sessionB!.self.publicKey));
  // metadata
  expect(sessionA.self.metadata, equals(sessionB!.peer.metadata));
  expect(sessionB!.self.metadata, equals(sessionA.peer.metadata));

  // update pairing state beforehand
  pairingA = clientA.pairing.get(pairingA.topic);
  pairingB = clientB.pairing.get(pairingB!.topic);

  // topic
  expect(pairingA.topic, equals(pairingB!.topic));
  // relay
  expect(pairingA.relay, equals(TEST_RELAY_OPTIONS));
  expect(pairingA.relay, equals(pairingB!.relay));
  // active
  expect(pairingA.active, equals(true));
  expect(pairingA.active, equals(pairingB!.active));
  // metadata
  expect(pairingA.peerMetadata, equals(sessionA.peer.metadata));
  expect(pairingB!.peerMetadata, equals(sessionB!.peer.metadata));

  return Connection(
    pairingA: pairingA,
    sessionA: sessionA,
    clientAConnectLatencyMs: clientAConnectLatencyMs,
    settlePairingLatencyMs: settlePairingLatencyMs,
  );
}
