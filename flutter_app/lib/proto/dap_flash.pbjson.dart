// This is a generated file - do not edit.
//
// Generated from dap_flash.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use probeDescriptor instead')
const Probe$json = {
  '1': 'Probe',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'vendor', '3': 3, '4': 1, '5': 9, '10': 'vendor'},
    {'1': 'serial_number', '3': 4, '4': 1, '5': 9, '10': 'serialNumber'},
  ],
};

/// Descriptor for `Probe`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List probeDescriptor = $convert.base64Decode(
    'CgVQcm9iZRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIWCgZ2ZW5kb3IYAy'
    'ABKAlSBnZlbmRvchIjCg1zZXJpYWxfbnVtYmVyGAQgASgJUgxzZXJpYWxOdW1iZXI=');

@$core.Deprecated('Use probeListDescriptor instead')
const ProbeList$json = {
  '1': 'ProbeList',
  '2': [
    {
      '1': 'probes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.dap_flash.Probe',
      '10': 'probes'
    },
  ],
};

/// Descriptor for `ProbeList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List probeListDescriptor = $convert.base64Decode(
    'CglQcm9iZUxpc3QSKAoGcHJvYmVzGAEgAygLMhAuZGFwX2ZsYXNoLlByb2JlUgZwcm9iZXM=');

@$core.Deprecated('Use connectRequestDescriptor instead')
const ConnectRequest$json = {
  '1': 'ConnectRequest',
  '2': [
    {'1': 'probe_id', '3': 1, '4': 1, '5': 9, '10': 'probeId'},
    {'1': 'target', '3': 2, '4': 1, '5': 9, '10': 'target'},
    {'1': 'frequency', '3': 3, '4': 1, '5': 5, '10': 'frequency'},
    {'1': 'protocol', '3': 4, '4': 1, '5': 9, '10': 'protocol'},
  ],
};

/// Descriptor for `ConnectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectRequestDescriptor = $convert.base64Decode(
    'Cg5Db25uZWN0UmVxdWVzdBIZCghwcm9iZV9pZBgBIAEoCVIHcHJvYmVJZBIWCgZ0YXJnZXQYAi'
    'ABKAlSBnRhcmdldBIcCglmcmVxdWVuY3kYAyABKAVSCWZyZXF1ZW5jeRIaCghwcm90b2NvbBgE'
    'IAEoCVIIcHJvdG9jb2w=');

@$core.Deprecated('Use connectResponseDescriptor instead')
const ConnectResponse$json = {
  '1': 'ConnectResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'target_name', '3': 3, '4': 1, '5': 9, '10': 'targetName'},
  ],
};

/// Descriptor for `ConnectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectResponseDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIjCg1lcnJvcl9tZX'
    'NzYWdlGAIgASgJUgxlcnJvck1lc3NhZ2USHwoLdGFyZ2V0X25hbWUYAyABKAlSCnRhcmdldE5h'
    'bWU=');

@$core.Deprecated('Use flashRequestDescriptor instead')
const FlashRequest$json = {
  '1': 'FlashRequest',
  '2': [
    {'1': 'firmware_path', '3': 1, '4': 1, '5': 9, '10': 'firmwarePath'},
    {'1': 'start_address', '3': 2, '4': 1, '5': 3, '10': 'startAddress'},
    {'1': 'driver', '3': 3, '4': 1, '5': 9, '10': 'driver'},
  ],
};

/// Descriptor for `FlashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flashRequestDescriptor = $convert.base64Decode(
    'CgxGbGFzaFJlcXVlc3QSIwoNZmlybXdhcmVfcGF0aBgBIAEoCVIMZmlybXdhcmVQYXRoEiMKDX'
    'N0YXJ0X2FkZHJlc3MYAiABKANSDHN0YXJ0QWRkcmVzcxIWCgZkcml2ZXIYAyABKAlSBmRyaXZl'
    'cg==');

@$core.Deprecated('Use progressUpdateDescriptor instead')
const ProgressUpdate$json = {
  '1': 'ProgressUpdate',
  '2': [
    {
      '1': 'phase',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.dap_flash.ProgressUpdate.Phase',
      '10': 'phase'
    },
    {'1': 'progress', '3': 2, '4': 1, '5': 2, '10': 'progress'},
    {'1': 'bytes_written', '3': 3, '4': 1, '5': 3, '10': 'bytesWritten'},
    {'1': 'total_bytes', '3': 4, '4': 1, '5': 3, '10': 'totalBytes'},
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
  ],
  '4': [ProgressUpdate_Phase$json],
};

@$core.Deprecated('Use progressUpdateDescriptor instead')
const ProgressUpdate_Phase$json = {
  '1': 'Phase',
  '2': [
    {'1': 'CONNECTING', '2': 0},
    {'1': 'ERASING', '2': 1},
    {'1': 'PROGRAMMING', '2': 2},
    {'1': 'VERIFYING', '2': 3},
    {'1': 'RESETTING', '2': 4},
  ],
};

/// Descriptor for `ProgressUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List progressUpdateDescriptor = $convert.base64Decode(
    'Cg5Qcm9ncmVzc1VwZGF0ZRI1CgVwaGFzZRgBIAEoDjIfLmRhcF9mbGFzaC5Qcm9ncmVzc1VwZG'
    'F0ZS5QaGFzZVIFcGhhc2USGgoIcHJvZ3Jlc3MYAiABKAJSCHByb2dyZXNzEiMKDWJ5dGVzX3dy'
    'aXR0ZW4YAyABKANSDGJ5dGVzV3JpdHRlbhIfCgt0b3RhbF9ieXRlcxgEIAEoA1IKdG90YWxCeX'
    'RlcxIYCgdtZXNzYWdlGAUgASgJUgdtZXNzYWdlIlMKBVBoYXNlEg4KCkNPTk5FQ1RJTkcQABIL'
    'CgdFUkFTSU5HEAESDwoLUFJPR1JBTU1JTkcQAhINCglWRVJJRllJTkcQAxINCglSRVNFVFRJTk'
    'cQBA==');

@$core.Deprecated('Use operationResultDescriptor instead')
const OperationResult$json = {
  '1': 'OperationResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `OperationResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationResultDescriptor = $convert.base64Decode(
    'Cg9PcGVyYXRpb25SZXN1bHQSGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGA'
    'IgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use chipIdResultDescriptor instead')
const ChipIdResult$json = {
  '1': 'ChipIdResult',
  '2': [
    {'1': 'chip_id', '3': 1, '4': 1, '5': 13, '10': 'chipId'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `ChipIdResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chipIdResultDescriptor = $convert.base64Decode(
    'CgxDaGlwSWRSZXN1bHQSFwoHY2hpcF9pZBgBIAEoDVIGY2hpcElkEiAKC2Rlc2NyaXB0aW9uGA'
    'IgASgJUgtkZXNjcmlwdGlvbg==');

@$core.Deprecated('Use eraseRequestDescriptor instead')
const EraseRequest$json = {
  '1': 'EraseRequest',
  '2': [
    {'1': 'mode', '3': 1, '4': 1, '5': 9, '10': 'mode'},
  ],
};

/// Descriptor for `EraseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eraseRequestDescriptor =
    $convert.base64Decode('CgxFcmFzZVJlcXVlc3QSEgoEbW9kZRgBIAEoCVIEbW9kZQ==');

@$core.Deprecated('Use packInfoDescriptor instead')
const PackInfo$json = {
  '1': 'PackInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'vendor', '3': 2, '4': 1, '5': 9, '10': 'vendor'},
    {'1': 'version', '3': 3, '4': 1, '5': 9, '10': 'version'},
    {'1': 'path', '3': 4, '4': 1, '5': 9, '10': 'path'},
    {'1': 'supported_chips', '3': 5, '4': 3, '5': 9, '10': 'supportedChips'},
    {'1': 'download_url', '3': 6, '4': 1, '5': 9, '10': 'downloadUrl'},
  ],
};

/// Descriptor for `PackInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packInfoDescriptor = $convert.base64Decode(
    'CghQYWNrSW5mbxISCgRuYW1lGAEgASgJUgRuYW1lEhYKBnZlbmRvchgCIAEoCVIGdmVuZG9yEh'
    'gKB3ZlcnNpb24YAyABKAlSB3ZlcnNpb24SEgoEcGF0aBgEIAEoCVIEcGF0aBInCg9zdXBwb3J0'
    'ZWRfY2hpcHMYBSADKAlSDnN1cHBvcnRlZENoaXBzEiEKDGRvd25sb2FkX3VybBgGIAEoCVILZG'
    '93bmxvYWRVcmw=');

@$core.Deprecated('Use packListDescriptor instead')
const PackList$json = {
  '1': 'PackList',
  '2': [
    {
      '1': 'packs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.dap_flash.PackInfo',
      '10': 'packs'
    },
  ],
};

/// Descriptor for `PackList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packListDescriptor = $convert.base64Decode(
    'CghQYWNrTGlzdBIpCgVwYWNrcxgBIAMoCzITLmRhcF9mbGFzaC5QYWNrSW5mb1IFcGFja3M=');

@$core.Deprecated('Use searchRequestDescriptor instead')
const SearchRequest$json = {
  '1': 'SearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `SearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchRequestDescriptor = $convert
    .base64Decode('Cg1TZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeQ==');

@$core.Deprecated('Use packSearchResultDescriptor instead')
const PackSearchResult$json = {
  '1': 'PackSearchResult',
  '2': [
    {
      '1': 'packs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.dap_flash.PackInfo',
      '10': 'packs'
    },
  ],
};

/// Descriptor for `PackSearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packSearchResultDescriptor = $convert.base64Decode(
    'ChBQYWNrU2VhcmNoUmVzdWx0EikKBXBhY2tzGAEgAygLMhMuZGFwX2ZsYXNoLlBhY2tJbmZvUg'
    'VwYWNrcw==');

@$core.Deprecated('Use downloadRequestDescriptor instead')
const DownloadRequest$json = {
  '1': 'DownloadRequest',
  '2': [
    {'1': 'pack_url', '3': 1, '4': 1, '5': 9, '10': 'packUrl'},
    {'1': 'pack_name', '3': 2, '4': 1, '5': 9, '10': 'packName'},
  ],
};

/// Descriptor for `DownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadRequestDescriptor = $convert.base64Decode(
    'Cg9Eb3dubG9hZFJlcXVlc3QSGQoIcGFja191cmwYASABKAlSB3BhY2tVcmwSGwoJcGFja19uYW'
    '1lGAIgASgJUghwYWNrTmFtZQ==');

@$core.Deprecated('Use flashRecordDescriptor instead')
const FlashRecord$json = {
  '1': 'FlashRecord',
  '2': [
    {'1': 'firmware_path', '3': 1, '4': 1, '5': 9, '10': 'firmwarePath'},
    {'1': 'firmware_hash', '3': 2, '4': 1, '5': 9, '10': 'firmwareHash'},
    {'1': 'chip_name', '3': 3, '4': 1, '5': 9, '10': 'chipName'},
    {'1': 'probe_name', '3': 4, '4': 1, '5': 9, '10': 'probeName'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'success', '3': 6, '4': 1, '5': 8, '10': 'success'},
    {'1': 'duration_ms', '3': 7, '4': 1, '5': 3, '10': 'durationMs'},
    {'1': 'error_message', '3': 8, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `FlashRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flashRecordDescriptor = $convert.base64Decode(
    'CgtGbGFzaFJlY29yZBIjCg1maXJtd2FyZV9wYXRoGAEgASgJUgxmaXJtd2FyZVBhdGgSIwoNZm'
    'lybXdhcmVfaGFzaBgCIAEoCVIMZmlybXdhcmVIYXNoEhsKCWNoaXBfbmFtZRgDIAEoCVIIY2hp'
    'cE5hbWUSHQoKcHJvYmVfbmFtZRgEIAEoCVIJcHJvYmVOYW1lEhwKCXRpbWVzdGFtcBgFIAEoA1'
    'IJdGltZXN0YW1wEhgKB3N1Y2Nlc3MYBiABKAhSB3N1Y2Nlc3MSHwoLZHVyYXRpb25fbXMYByAB'
    'KANSCmR1cmF0aW9uTXMSIwoNZXJyb3JfbWVzc2FnZRgIIAEoCVIMZXJyb3JNZXNzYWdl');

@$core.Deprecated('Use flashHistoryListDescriptor instead')
const FlashHistoryList$json = {
  '1': 'FlashHistoryList',
  '2': [
    {
      '1': 'records',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.dap_flash.FlashRecord',
      '10': 'records'
    },
  ],
};

/// Descriptor for `FlashHistoryList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flashHistoryListDescriptor = $convert.base64Decode(
    'ChBGbGFzaEhpc3RvcnlMaXN0EjAKB3JlY29yZHMYASADKAsyFi5kYXBfZmxhc2guRmxhc2hSZW'
    'NvcmRSB3JlY29yZHM=');

@$core.Deprecated('Use installPackRequestDescriptor instead')
const InstallPackRequest$json = {
  '1': 'InstallPackRequest',
  '2': [
    {'1': 'pack_path', '3': 1, '4': 1, '5': 9, '10': 'packPath'},
  ],
};

/// Descriptor for `InstallPackRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List installPackRequestDescriptor =
    $convert.base64Decode(
        'ChJJbnN0YWxsUGFja1JlcXVlc3QSGwoJcGFja19wYXRoGAEgASgJUghwYWNrUGF0aA==');

@$core.Deprecated('Use installedPackDescriptor instead')
const InstalledPack$json = {
  '1': 'InstalledPack',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'vendor', '3': 2, '4': 1, '5': 9, '10': 'vendor'},
    {'1': 'version', '3': 3, '4': 1, '5': 9, '10': 'version'},
    {'1': 'supported_chips', '3': 4, '4': 3, '5': 9, '10': 'supportedChips'},
  ],
};

/// Descriptor for `InstalledPack`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List installedPackDescriptor = $convert.base64Decode(
    'Cg1JbnN0YWxsZWRQYWNrEhIKBG5hbWUYASABKAlSBG5hbWUSFgoGdmVuZG9yGAIgASgJUgZ2ZW'
    '5kb3ISGAoHdmVyc2lvbhgDIAEoCVIHdmVyc2lvbhInCg9zdXBwb3J0ZWRfY2hpcHMYBCADKAlS'
    'DnN1cHBvcnRlZENoaXBz');

@$core.Deprecated('Use installedPackListDescriptor instead')
const InstalledPackList$json = {
  '1': 'InstalledPackList',
  '2': [
    {
      '1': 'packs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.dap_flash.InstalledPack',
      '10': 'packs'
    },
  ],
};

/// Descriptor for `InstalledPackList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List installedPackListDescriptor = $convert.base64Decode(
    'ChFJbnN0YWxsZWRQYWNrTGlzdBIuCgVwYWNrcxgBIAMoCzIYLmRhcF9mbGFzaC5JbnN0YWxsZW'
    'RQYWNrUgVwYWNrcw==');

@$core.Deprecated('Use getProbeDetailsRequestDescriptor instead')
const GetProbeDetailsRequest$json = {
  '1': 'GetProbeDetailsRequest',
  '2': [
    {'1': 'probe_id', '3': 1, '4': 1, '5': 9, '10': 'probeId'},
  ],
};

/// Descriptor for `GetProbeDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProbeDetailsRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRQcm9iZURldGFpbHNSZXF1ZXN0EhkKCHByb2JlX2lkGAEgASgJUgdwcm9iZUlk');

@$core.Deprecated('Use probeDetailsDescriptor instead')
const ProbeDetails$json = {
  '1': 'ProbeDetails',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'vendor', '3': 3, '4': 1, '5': 9, '10': 'vendor'},
    {'1': 'serial_number', '3': 4, '4': 1, '5': 9, '10': 'serialNumber'},
    {'1': 'firmware_version', '3': 5, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {'1': 'hardware_version', '3': 6, '4': 1, '5': 9, '10': 'hardwareVersion'},
    {'1': 'target_voltage', '3': 7, '4': 1, '5': 2, '10': 'targetVoltage'},
    {'1': 'is_connected', '3': 8, '4': 1, '5': 8, '10': 'isConnected'},
  ],
};

/// Descriptor for `ProbeDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List probeDetailsDescriptor = $convert.base64Decode(
    'CgxQcm9iZURldGFpbHMSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSFgoGdm'
    'VuZG9yGAMgASgJUgZ2ZW5kb3ISIwoNc2VyaWFsX251bWJlchgEIAEoCVIMc2VyaWFsTnVtYmVy'
    'EikKEGZpcm13YXJlX3ZlcnNpb24YBSABKAlSD2Zpcm13YXJlVmVyc2lvbhIpChBoYXJkd2FyZV'
    '92ZXJzaW9uGAYgASgJUg9oYXJkd2FyZVZlcnNpb24SJQoOdGFyZ2V0X3ZvbHRhZ2UYByABKAJS'
    'DXRhcmdldFZvbHRhZ2USIQoMaXNfY29ubmVjdGVkGAggASgIUgtpc0Nvbm5lY3RlZA==');

@$core.Deprecated('Use resetRequestDescriptor instead')
const ResetRequest$json = {
  '1': 'ResetRequest',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.dap_flash.ResetRequest.ResetType',
      '10': 'type'
    },
  ],
  '4': [ResetRequest_ResetType$json],
};

@$core.Deprecated('Use resetRequestDescriptor instead')
const ResetRequest_ResetType$json = {
  '1': 'ResetType',
  '2': [
    {'1': 'SOFTWARE', '2': 0},
    {'1': 'HARDWARE', '2': 1},
  ],
};

/// Descriptor for `ResetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resetRequestDescriptor = $convert.base64Decode(
    'CgxSZXNldFJlcXVlc3QSNQoEdHlwZRgBIAEoDjIhLmRhcF9mbGFzaC5SZXNldFJlcXVlc3QuUm'
    'VzZXRUeXBlUgR0eXBlIicKCVJlc2V0VHlwZRIMCghTT0ZUV0FSRRAAEgwKCEhBUkRXQVJFEAE=');

@$core.Deprecated('Use previewRequestDescriptor instead')
const PreviewRequest$json = {
  '1': 'PreviewRequest',
  '2': [
    {'1': 'file_path', '3': 1, '4': 1, '5': 9, '10': 'filePath'},
    {'1': 'offset', '3': 2, '4': 1, '5': 3, '10': 'offset'},
    {'1': 'length', '3': 3, '4': 1, '5': 5, '10': 'length'},
  ],
};

/// Descriptor for `PreviewRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewRequestDescriptor = $convert.base64Decode(
    'Cg5QcmV2aWV3UmVxdWVzdBIbCglmaWxlX3BhdGgYASABKAlSCGZpbGVQYXRoEhYKBm9mZnNldB'
    'gCIAEoA1IGb2Zmc2V0EhYKBmxlbmd0aBgDIAEoBVIGbGVuZ3Ro');

@$core.Deprecated('Use previewResponseDescriptor instead')
const PreviewResponse$json = {
  '1': 'PreviewResponse',
  '2': [
    {'1': 'hex_dump', '3': 1, '4': 1, '5': 9, '10': 'hexDump'},
    {'1': 'total_size', '3': 2, '4': 1, '5': 3, '10': 'totalSize'},
    {'1': 'file_format', '3': 3, '4': 1, '5': 9, '10': 'fileFormat'},
  ],
};

/// Descriptor for `PreviewResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewResponseDescriptor = $convert.base64Decode(
    'Cg9QcmV2aWV3UmVzcG9uc2USGQoIaGV4X2R1bXAYASABKAlSB2hleER1bXASHQoKdG90YWxfc2'
    'l6ZRgCIAEoA1IJdG90YWxTaXplEh8KC2ZpbGVfZm9ybWF0GAMgASgJUgpmaWxlRm9ybWF0');

@$core.Deprecated('Use fileInfoDescriptor instead')
const FileInfo$json = {
  '1': 'FileInfo',
  '2': [
    {'1': 'format', '3': 1, '4': 1, '5': 9, '10': 'format'},
    {'1': 'total_size', '3': 2, '4': 1, '5': 3, '10': 'totalSize'},
    {'1': 'base_address', '3': 3, '4': 1, '5': 3, '10': 'baseAddress'},
  ],
};

/// Descriptor for `FileInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileInfoDescriptor = $convert.base64Decode(
    'CghGaWxlSW5mbxIWCgZmb3JtYXQYASABKAlSBmZvcm1hdBIdCgp0b3RhbF9zaXplGAIgASgDUg'
    'l0b3RhbFNpemUSIQoMYmFzZV9hZGRyZXNzGAMgASgDUgtiYXNlQWRkcmVzcw==');

@$core.Deprecated('Use listProbesRequestDescriptor instead')
const ListProbesRequest$json = {
  '1': 'ListProbesRequest',
};

/// Descriptor for `ListProbesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProbesRequestDescriptor =
    $convert.base64Decode('ChFMaXN0UHJvYmVzUmVxdWVzdA==');

@$core.Deprecated('Use disconnectProbeRequestDescriptor instead')
const DisconnectProbeRequest$json = {
  '1': 'DisconnectProbeRequest',
};

/// Descriptor for `DisconnectProbeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disconnectProbeRequestDescriptor =
    $convert.base64Decode('ChZEaXNjb25uZWN0UHJvYmVSZXF1ZXN0');

@$core.Deprecated('Use disconnectProbeResponseDescriptor instead')
const DisconnectProbeResponse$json = {
  '1': 'DisconnectProbeResponse',
};

/// Descriptor for `DisconnectProbeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disconnectProbeResponseDescriptor =
    $convert.base64Decode('ChdEaXNjb25uZWN0UHJvYmVSZXNwb25zZQ==');

@$core.Deprecated('Use readChipIdRequestDescriptor instead')
const ReadChipIdRequest$json = {
  '1': 'ReadChipIdRequest',
};

/// Descriptor for `ReadChipIdRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readChipIdRequestDescriptor =
    $convert.base64Decode('ChFSZWFkQ2hpcElkUmVxdWVzdA==');

@$core.Deprecated('Use listPacksRequestDescriptor instead')
const ListPacksRequest$json = {
  '1': 'ListPacksRequest',
};

/// Descriptor for `ListPacksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPacksRequestDescriptor =
    $convert.base64Decode('ChBMaXN0UGFja3NSZXF1ZXN0');

@$core.Deprecated('Use listInstalledPacksRequestDescriptor instead')
const ListInstalledPacksRequest$json = {
  '1': 'ListInstalledPacksRequest',
};

/// Descriptor for `ListInstalledPacksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInstalledPacksRequestDescriptor =
    $convert.base64Decode('ChlMaXN0SW5zdGFsbGVkUGFja3NSZXF1ZXN0');

@$core.Deprecated('Use getFlashHistoryRequestDescriptor instead')
const GetFlashHistoryRequest$json = {
  '1': 'GetFlashHistoryRequest',
};

/// Descriptor for `GetFlashHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFlashHistoryRequestDescriptor =
    $convert.base64Decode('ChZHZXRGbGFzaEhpc3RvcnlSZXF1ZXN0');
