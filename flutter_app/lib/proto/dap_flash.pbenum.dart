// This is a generated file - do not edit.
//
// Generated from dap_flash.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ProgressUpdate_Phase extends $pb.ProtobufEnum {
  static const ProgressUpdate_Phase CONNECTING =
      ProgressUpdate_Phase._(0, _omitEnumNames ? '' : 'CONNECTING');
  static const ProgressUpdate_Phase ERASING =
      ProgressUpdate_Phase._(1, _omitEnumNames ? '' : 'ERASING');
  static const ProgressUpdate_Phase PROGRAMMING =
      ProgressUpdate_Phase._(2, _omitEnumNames ? '' : 'PROGRAMMING');
  static const ProgressUpdate_Phase VERIFYING =
      ProgressUpdate_Phase._(3, _omitEnumNames ? '' : 'VERIFYING');
  static const ProgressUpdate_Phase RESETTING =
      ProgressUpdate_Phase._(4, _omitEnumNames ? '' : 'RESETTING');

  static const $core.List<ProgressUpdate_Phase> values = <ProgressUpdate_Phase>[
    CONNECTING,
    ERASING,
    PROGRAMMING,
    VERIFYING,
    RESETTING,
  ];

  static final $core.List<ProgressUpdate_Phase?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ProgressUpdate_Phase? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProgressUpdate_Phase._(super.value, super.name);
}

class ResetRequest_ResetType extends $pb.ProtobufEnum {
  static const ResetRequest_ResetType SOFTWARE =
      ResetRequest_ResetType._(0, _omitEnumNames ? '' : 'SOFTWARE');
  static const ResetRequest_ResetType HARDWARE =
      ResetRequest_ResetType._(1, _omitEnumNames ? '' : 'HARDWARE');

  static const $core.List<ResetRequest_ResetType> values =
      <ResetRequest_ResetType>[
    SOFTWARE,
    HARDWARE,
  ];

  static final $core.List<ResetRequest_ResetType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static ResetRequest_ResetType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ResetRequest_ResetType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
