# Protocol semantics and structured payloads

This guide extends [capture and process analysis](process-and-reconstruction.md) and [custom binary formats](formats-and-runtimes.md). Template: [protocol study](../assets/templates/protocol-study.yaml).

## Tool roles

Wireshark/TShark decode supported protocols from captures. [Scapy](https://scapy.readthedocs.io/en/latest/) supports programmable packet parsing, construction and selected protocol layers. Kaitai Struct or a bounded parser handles identified custom payloads. Schema tools such as protoc or flatc are useful when matching Protobuf/FlatBuffers definitions are available. ASN.1, CBOR and MessagePack need matching format/schema semantics and resource limits.

Offline parsing and packet construction do not imply transmission. An active exchange additionally specifies endpoint, session/reset, rate, permitted effects and stopping conditions. Protocol fuzzing uses the [testing guide](testing-and-constraints.md).

## Message reconstruction

Bind the raw capture, capture interface/layer, directions, clocks, filters and loss information. Reassemble transport streams with sequence numbers, retransmission/overlap policy, fragmentation, session boundaries and gaps. Application-message framing can depend on handshake state, negotiated parameters, length fields or compression. Keep the packet-to-message mapping.

Decode layers in order and retain intermediate bytes with their transformations. Decrypted application data requires actual keys/session secrets or an already decrypted observation; ciphertext patterns do not establish plaintext. TLS/QUIC versions, sessions and key availability must match the capture. A proxy capture may expose a different endpoint implementation from the original service.

## Recover fields and state

Collect examples with independently known actions and vary one property at a time where practical. Record each field's location, width, byte order, encoding, scaling, length relation, checksum coverage and confidence. Unknown Protobuf field numbers or wire types do not reveal original field names or every schema constraint. A syntactically decoded CBOR/ASN.1 object can still have unresolved application meaning.

Construct a finite state/sequence model including prerequisites, request/response association, asynchronous events, errors, timeouts, reconnects and persistent state. Separate direction-dependent messages and negotiated versions. A single successful exchange does not establish all accepted inputs or error behavior.

Check hypotheses through known-state captures, independent parsers, valid encode/decode cases where an encoder exists, and controlled replay where authorized. Preserve original versus normalized fields; counters, timestamps and checksums cannot be discarded if they affect acceptance. An encode/decode round trip primarily tests internal consistency.

## Device and industrial protocols

USB transfers, Bluetooth HCI/ATT/GATT, CAN and serial buses retain their acquisition-layer context through [hardware methods](firmware-specializations.md) and [bus decoding](firmware-lab.md). Industrial protocols may connect message fields to live I/O or controller state. An offline decoder can describe those fields without initiating a state change.

For a remote fingerprint, identify the exact response feature, request/session precondition, build/configuration, intermediaries and comparison controls. Repeat across sessions and relevant versions. Report whether the feature identifies a protocol family, implementation, configuration, or specific build; timing-only or shared-library signals often have weaker attribution.

**Deliverable:** message grammar or schema, state model, raw-message references, decoder and test cases where needed, confirmed fields, competing interpretations and coverage gaps.
