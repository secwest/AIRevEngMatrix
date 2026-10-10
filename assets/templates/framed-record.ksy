meta:
  id: framed_record
  title: Synthetic bounded record
  endian: le
doc: A synthetic record with fixed magic, version, bounded length, and payload.
seq:
  - id: magic
    contents: [0x52, 0x56, 0x4d, 0x58]
  - id: version
    type: u1
    valid: 1
  - id: payload_length
    type: u2
    valid:
      max: 1024
  - id: payload
    size: payload_length
