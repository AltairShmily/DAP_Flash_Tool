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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'dap_flash.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'dap_flash.pbenum.dart';

class Probe extends $pb.GeneratedMessage {
  factory Probe({
    $core.String? id,
    $core.String? name,
    $core.String? vendor,
    $core.String? serialNumber,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (vendor != null) result.vendor = vendor;
    if (serialNumber != null) result.serialNumber = serialNumber;
    return result;
  }

  Probe._();

  factory Probe.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Probe.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Probe',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'vendor')
    ..aOS(4, _omitFieldNames ? '' : 'serialNumber')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Probe clone() => Probe()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Probe copyWith(void Function(Probe) updates) =>
      super.copyWith((message) => updates(message as Probe)) as Probe;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Probe create() => Probe._();
  @$core.override
  Probe createEmptyInstance() => create();
  static $pb.PbList<Probe> createRepeated() => $pb.PbList<Probe>();
  @$core.pragma('dart2js:noInline')
  static Probe getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Probe>(create);
  static Probe? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get vendor => $_getSZ(2);
  @$pb.TagNumber(3)
  set vendor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVendor() => $_has(2);
  @$pb.TagNumber(3)
  void clearVendor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get serialNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set serialNumber($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSerialNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearSerialNumber() => $_clearField(4);
}

class ProbeList extends $pb.GeneratedMessage {
  factory ProbeList({
    $core.Iterable<Probe>? probes,
  }) {
    final result = create();
    if (probes != null) result.probes.addAll(probes);
    return result;
  }

  ProbeList._();

  factory ProbeList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProbeList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProbeList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..pc<Probe>(1, _omitFieldNames ? '' : 'probes', $pb.PbFieldType.PM,
        subBuilder: Probe.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProbeList clone() => ProbeList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProbeList copyWith(void Function(ProbeList) updates) =>
      super.copyWith((message) => updates(message as ProbeList)) as ProbeList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProbeList create() => ProbeList._();
  @$core.override
  ProbeList createEmptyInstance() => create();
  static $pb.PbList<ProbeList> createRepeated() => $pb.PbList<ProbeList>();
  @$core.pragma('dart2js:noInline')
  static ProbeList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProbeList>(create);
  static ProbeList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Probe> get probes => $_getList(0);
}

class ConnectRequest extends $pb.GeneratedMessage {
  factory ConnectRequest({
    $core.String? probeId,
    $core.String? target,
    $core.int? frequency,
    $core.String? protocol,
  }) {
    final result = create();
    if (probeId != null) result.probeId = probeId;
    if (target != null) result.target = target;
    if (frequency != null) result.frequency = frequency;
    if (protocol != null) result.protocol = protocol;
    return result;
  }

  ConnectRequest._();

  factory ConnectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'probeId')
    ..aOS(2, _omitFieldNames ? '' : 'target')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'frequency', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'protocol')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectRequest clone() => ConnectRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectRequest copyWith(void Function(ConnectRequest) updates) =>
      super.copyWith((message) => updates(message as ConnectRequest))
          as ConnectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectRequest create() => ConnectRequest._();
  @$core.override
  ConnectRequest createEmptyInstance() => create();
  static $pb.PbList<ConnectRequest> createRepeated() =>
      $pb.PbList<ConnectRequest>();
  @$core.pragma('dart2js:noInline')
  static ConnectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectRequest>(create);
  static ConnectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get probeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set probeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProbeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProbeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get target => $_getSZ(1);
  @$pb.TagNumber(2)
  set target($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTarget() => $_has(1);
  @$pb.TagNumber(2)
  void clearTarget() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get frequency => $_getIZ(2);
  @$pb.TagNumber(3)
  set frequency($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFrequency() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrequency() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get protocol => $_getSZ(3);
  @$pb.TagNumber(4)
  set protocol($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProtocol() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocol() => $_clearField(4);
}

class ConnectResponse extends $pb.GeneratedMessage {
  factory ConnectResponse({
    $core.bool? success,
    $core.String? errorMessage,
    $core.String? targetName,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (targetName != null) result.targetName = targetName;
    return result;
  }

  ConnectResponse._();

  factory ConnectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOS(3, _omitFieldNames ? '' : 'targetName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectResponse clone() => ConnectResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectResponse copyWith(void Function(ConnectResponse) updates) =>
      super.copyWith((message) => updates(message as ConnectResponse))
          as ConnectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectResponse create() => ConnectResponse._();
  @$core.override
  ConnectResponse createEmptyInstance() => create();
  static $pb.PbList<ConnectResponse> createRepeated() =>
      $pb.PbList<ConnectResponse>();
  @$core.pragma('dart2js:noInline')
  static ConnectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectResponse>(create);
  static ConnectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get targetName => $_getSZ(2);
  @$pb.TagNumber(3)
  set targetName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetName() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetName() => $_clearField(3);
}

class FlashRequest extends $pb.GeneratedMessage {
  factory FlashRequest({
    $core.String? firmwarePath,
    $fixnum.Int64? startAddress,
    $core.String? driver,
  }) {
    final result = create();
    if (firmwarePath != null) result.firmwarePath = firmwarePath;
    if (startAddress != null) result.startAddress = startAddress;
    if (driver != null) result.driver = driver;
    return result;
  }

  FlashRequest._();

  factory FlashRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlashRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlashRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'firmwarePath')
    ..aInt64(2, _omitFieldNames ? '' : 'startAddress')
    ..aOS(3, _omitFieldNames ? '' : 'driver')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashRequest clone() => FlashRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashRequest copyWith(void Function(FlashRequest) updates) =>
      super.copyWith((message) => updates(message as FlashRequest))
          as FlashRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlashRequest create() => FlashRequest._();
  @$core.override
  FlashRequest createEmptyInstance() => create();
  static $pb.PbList<FlashRequest> createRepeated() =>
      $pb.PbList<FlashRequest>();
  @$core.pragma('dart2js:noInline')
  static FlashRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlashRequest>(create);
  static FlashRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get firmwarePath => $_getSZ(0);
  @$pb.TagNumber(1)
  set firmwarePath($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFirmwarePath() => $_has(0);
  @$pb.TagNumber(1)
  void clearFirmwarePath() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startAddress => $_getI64(1);
  @$pb.TagNumber(2)
  set startAddress($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get driver => $_getSZ(2);
  @$pb.TagNumber(3)
  set driver($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDriver() => $_has(2);
  @$pb.TagNumber(3)
  void clearDriver() => $_clearField(3);
}

class ProgressUpdate extends $pb.GeneratedMessage {
  factory ProgressUpdate({
    ProgressUpdate_Phase? phase,
    $core.double? progress,
    $fixnum.Int64? bytesWritten,
    $fixnum.Int64? totalBytes,
    $core.String? message,
  }) {
    final result = create();
    if (phase != null) result.phase = phase;
    if (progress != null) result.progress = progress;
    if (bytesWritten != null) result.bytesWritten = bytesWritten;
    if (totalBytes != null) result.totalBytes = totalBytes;
    if (message != null) result.message = message;
    return result;
  }

  ProgressUpdate._();

  factory ProgressUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProgressUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProgressUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..e<ProgressUpdate_Phase>(
        1, _omitFieldNames ? '' : 'phase', $pb.PbFieldType.OE,
        defaultOrMaker: ProgressUpdate_Phase.CONNECTING,
        valueOf: ProgressUpdate_Phase.valueOf,
        enumValues: ProgressUpdate_Phase.values)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'progress', $pb.PbFieldType.OF)
    ..aInt64(3, _omitFieldNames ? '' : 'bytesWritten')
    ..aInt64(4, _omitFieldNames ? '' : 'totalBytes')
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProgressUpdate clone() => ProgressUpdate()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProgressUpdate copyWith(void Function(ProgressUpdate) updates) =>
      super.copyWith((message) => updates(message as ProgressUpdate))
          as ProgressUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProgressUpdate create() => ProgressUpdate._();
  @$core.override
  ProgressUpdate createEmptyInstance() => create();
  static $pb.PbList<ProgressUpdate> createRepeated() =>
      $pb.PbList<ProgressUpdate>();
  @$core.pragma('dart2js:noInline')
  static ProgressUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProgressUpdate>(create);
  static ProgressUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  ProgressUpdate_Phase get phase => $_getN(0);
  @$pb.TagNumber(1)
  set phase(ProgressUpdate_Phase value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPhase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get progress => $_getN(1);
  @$pb.TagNumber(2)
  set progress($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProgress() => $_has(1);
  @$pb.TagNumber(2)
  void clearProgress() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get bytesWritten => $_getI64(2);
  @$pb.TagNumber(3)
  set bytesWritten($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytesWritten() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytesWritten() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set totalBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);
  @$pb.TagNumber(5)
  set message($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessage() => $_clearField(5);
}

class OperationResult extends $pb.GeneratedMessage {
  factory OperationResult({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  OperationResult._();

  factory OperationResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OperationResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OperationResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationResult clone() => OperationResult()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OperationResult copyWith(void Function(OperationResult) updates) =>
      super.copyWith((message) => updates(message as OperationResult))
          as OperationResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OperationResult create() => OperationResult._();
  @$core.override
  OperationResult createEmptyInstance() => create();
  static $pb.PbList<OperationResult> createRepeated() =>
      $pb.PbList<OperationResult>();
  @$core.pragma('dart2js:noInline')
  static OperationResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OperationResult>(create);
  static OperationResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class ChipIdResult extends $pb.GeneratedMessage {
  factory ChipIdResult({
    $core.int? chipId,
    $core.String? description,
  }) {
    final result = create();
    if (chipId != null) result.chipId = chipId;
    if (description != null) result.description = description;
    return result;
  }

  ChipIdResult._();

  factory ChipIdResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChipIdResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChipIdResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'chipId', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChipIdResult clone() => ChipIdResult()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChipIdResult copyWith(void Function(ChipIdResult) updates) =>
      super.copyWith((message) => updates(message as ChipIdResult))
          as ChipIdResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChipIdResult create() => ChipIdResult._();
  @$core.override
  ChipIdResult createEmptyInstance() => create();
  static $pb.PbList<ChipIdResult> createRepeated() =>
      $pb.PbList<ChipIdResult>();
  @$core.pragma('dart2js:noInline')
  static ChipIdResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChipIdResult>(create);
  static ChipIdResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get chipId => $_getIZ(0);
  @$pb.TagNumber(1)
  set chipId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChipId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChipId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);
}

class EraseRequest extends $pb.GeneratedMessage {
  factory EraseRequest({
    $core.String? mode,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    return result;
  }

  EraseRequest._();

  factory EraseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EraseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EraseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EraseRequest clone() => EraseRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EraseRequest copyWith(void Function(EraseRequest) updates) =>
      super.copyWith((message) => updates(message as EraseRequest))
          as EraseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EraseRequest create() => EraseRequest._();
  @$core.override
  EraseRequest createEmptyInstance() => create();
  static $pb.PbList<EraseRequest> createRepeated() =>
      $pb.PbList<EraseRequest>();
  @$core.pragma('dart2js:noInline')
  static EraseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EraseRequest>(create);
  static EraseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mode => $_getSZ(0);
  @$pb.TagNumber(1)
  set mode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);
}

class PackInfo extends $pb.GeneratedMessage {
  factory PackInfo({
    $core.String? name,
    $core.String? vendor,
    $core.String? version,
    $core.String? path,
    $core.Iterable<$core.String>? supportedChips,
    $core.String? downloadUrl,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (vendor != null) result.vendor = vendor;
    if (version != null) result.version = version;
    if (path != null) result.path = path;
    if (supportedChips != null) result.supportedChips.addAll(supportedChips);
    if (downloadUrl != null) result.downloadUrl = downloadUrl;
    return result;
  }

  PackInfo._();

  factory PackInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'vendor')
    ..aOS(3, _omitFieldNames ? '' : 'version')
    ..aOS(4, _omitFieldNames ? '' : 'path')
    ..pPS(5, _omitFieldNames ? '' : 'supportedChips')
    ..aOS(6, _omitFieldNames ? '' : 'downloadUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackInfo clone() => PackInfo()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackInfo copyWith(void Function(PackInfo) updates) =>
      super.copyWith((message) => updates(message as PackInfo)) as PackInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackInfo create() => PackInfo._();
  @$core.override
  PackInfo createEmptyInstance() => create();
  static $pb.PbList<PackInfo> createRepeated() => $pb.PbList<PackInfo>();
  @$core.pragma('dart2js:noInline')
  static PackInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PackInfo>(create);
  static PackInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get vendor => $_getSZ(1);
  @$pb.TagNumber(2)
  set vendor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVendor() => $_has(1);
  @$pb.TagNumber(2)
  void clearVendor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get version => $_getSZ(2);
  @$pb.TagNumber(3)
  set version($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get path => $_getSZ(3);
  @$pb.TagNumber(4)
  set path($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get supportedChips => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get downloadUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set downloadUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDownloadUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearDownloadUrl() => $_clearField(6);
}

class PackList extends $pb.GeneratedMessage {
  factory PackList({
    $core.Iterable<PackInfo>? packs,
  }) {
    final result = create();
    if (packs != null) result.packs.addAll(packs);
    return result;
  }

  PackList._();

  factory PackList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..pc<PackInfo>(1, _omitFieldNames ? '' : 'packs', $pb.PbFieldType.PM,
        subBuilder: PackInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackList clone() => PackList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackList copyWith(void Function(PackList) updates) =>
      super.copyWith((message) => updates(message as PackList)) as PackList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackList create() => PackList._();
  @$core.override
  PackList createEmptyInstance() => create();
  static $pb.PbList<PackList> createRepeated() => $pb.PbList<PackList>();
  @$core.pragma('dart2js:noInline')
  static PackList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PackList>(create);
  static PackList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PackInfo> get packs => $_getList(0);
}

class SearchRequest extends $pb.GeneratedMessage {
  factory SearchRequest({
    $core.String? query,
  }) {
    final result = create();
    if (query != null) result.query = query;
    return result;
  }

  SearchRequest._();

  factory SearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRequest clone() => SearchRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRequest copyWith(void Function(SearchRequest) updates) =>
      super.copyWith((message) => updates(message as SearchRequest))
          as SearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchRequest create() => SearchRequest._();
  @$core.override
  SearchRequest createEmptyInstance() => create();
  static $pb.PbList<SearchRequest> createRepeated() =>
      $pb.PbList<SearchRequest>();
  @$core.pragma('dart2js:noInline')
  static SearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchRequest>(create);
  static SearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);
}

class PackSearchResult extends $pb.GeneratedMessage {
  factory PackSearchResult({
    $core.Iterable<PackInfo>? packs,
  }) {
    final result = create();
    if (packs != null) result.packs.addAll(packs);
    return result;
  }

  PackSearchResult._();

  factory PackSearchResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackSearchResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackSearchResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..pc<PackInfo>(1, _omitFieldNames ? '' : 'packs', $pb.PbFieldType.PM,
        subBuilder: PackInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackSearchResult clone() => PackSearchResult()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackSearchResult copyWith(void Function(PackSearchResult) updates) =>
      super.copyWith((message) => updates(message as PackSearchResult))
          as PackSearchResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackSearchResult create() => PackSearchResult._();
  @$core.override
  PackSearchResult createEmptyInstance() => create();
  static $pb.PbList<PackSearchResult> createRepeated() =>
      $pb.PbList<PackSearchResult>();
  @$core.pragma('dart2js:noInline')
  static PackSearchResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackSearchResult>(create);
  static PackSearchResult? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PackInfo> get packs => $_getList(0);
}

class DownloadRequest extends $pb.GeneratedMessage {
  factory DownloadRequest({
    $core.String? packUrl,
    $core.String? packName,
  }) {
    final result = create();
    if (packUrl != null) result.packUrl = packUrl;
    if (packName != null) result.packName = packName;
    return result;
  }

  DownloadRequest._();

  factory DownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'packUrl')
    ..aOS(2, _omitFieldNames ? '' : 'packName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadRequest clone() => DownloadRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadRequest copyWith(void Function(DownloadRequest) updates) =>
      super.copyWith((message) => updates(message as DownloadRequest))
          as DownloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadRequest create() => DownloadRequest._();
  @$core.override
  DownloadRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadRequest> createRepeated() =>
      $pb.PbList<DownloadRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadRequest>(create);
  static DownloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get packUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set packUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get packName => $_getSZ(1);
  @$pb.TagNumber(2)
  set packName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPackName() => $_has(1);
  @$pb.TagNumber(2)
  void clearPackName() => $_clearField(2);
}

class FlashRecord extends $pb.GeneratedMessage {
  factory FlashRecord({
    $core.String? firmwarePath,
    $core.String? firmwareHash,
    $core.String? chipName,
    $core.String? probeName,
    $fixnum.Int64? timestamp,
    $core.bool? success,
    $fixnum.Int64? durationMs,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (firmwarePath != null) result.firmwarePath = firmwarePath;
    if (firmwareHash != null) result.firmwareHash = firmwareHash;
    if (chipName != null) result.chipName = chipName;
    if (probeName != null) result.probeName = probeName;
    if (timestamp != null) result.timestamp = timestamp;
    if (success != null) result.success = success;
    if (durationMs != null) result.durationMs = durationMs;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  FlashRecord._();

  factory FlashRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlashRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlashRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'firmwarePath')
    ..aOS(2, _omitFieldNames ? '' : 'firmwareHash')
    ..aOS(3, _omitFieldNames ? '' : 'chipName')
    ..aOS(4, _omitFieldNames ? '' : 'probeName')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..aOB(6, _omitFieldNames ? '' : 'success')
    ..aInt64(7, _omitFieldNames ? '' : 'durationMs')
    ..aOS(8, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashRecord clone() => FlashRecord()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashRecord copyWith(void Function(FlashRecord) updates) =>
      super.copyWith((message) => updates(message as FlashRecord))
          as FlashRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlashRecord create() => FlashRecord._();
  @$core.override
  FlashRecord createEmptyInstance() => create();
  static $pb.PbList<FlashRecord> createRepeated() => $pb.PbList<FlashRecord>();
  @$core.pragma('dart2js:noInline')
  static FlashRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlashRecord>(create);
  static FlashRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get firmwarePath => $_getSZ(0);
  @$pb.TagNumber(1)
  set firmwarePath($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFirmwarePath() => $_has(0);
  @$pb.TagNumber(1)
  void clearFirmwarePath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get firmwareHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set firmwareHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFirmwareHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirmwareHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get chipName => $_getSZ(2);
  @$pb.TagNumber(3)
  set chipName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChipName() => $_has(2);
  @$pb.TagNumber(3)
  void clearChipName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get probeName => $_getSZ(3);
  @$pb.TagNumber(4)
  set probeName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProbeName() => $_has(3);
  @$pb.TagNumber(4)
  void clearProbeName() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get success => $_getBF(5);
  @$pb.TagNumber(6)
  set success($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSuccess() => $_has(5);
  @$pb.TagNumber(6)
  void clearSuccess() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get durationMs => $_getI64(6);
  @$pb.TagNumber(7)
  set durationMs($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDurationMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearDurationMs() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get errorMessage => $_getSZ(7);
  @$pb.TagNumber(8)
  set errorMessage($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasErrorMessage() => $_has(7);
  @$pb.TagNumber(8)
  void clearErrorMessage() => $_clearField(8);
}

class FlashHistoryList extends $pb.GeneratedMessage {
  factory FlashHistoryList({
    $core.Iterable<FlashRecord>? records,
  }) {
    final result = create();
    if (records != null) result.records.addAll(records);
    return result;
  }

  FlashHistoryList._();

  factory FlashHistoryList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlashHistoryList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlashHistoryList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..pc<FlashRecord>(1, _omitFieldNames ? '' : 'records', $pb.PbFieldType.PM,
        subBuilder: FlashRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashHistoryList clone() => FlashHistoryList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashHistoryList copyWith(void Function(FlashHistoryList) updates) =>
      super.copyWith((message) => updates(message as FlashHistoryList))
          as FlashHistoryList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlashHistoryList create() => FlashHistoryList._();
  @$core.override
  FlashHistoryList createEmptyInstance() => create();
  static $pb.PbList<FlashHistoryList> createRepeated() =>
      $pb.PbList<FlashHistoryList>();
  @$core.pragma('dart2js:noInline')
  static FlashHistoryList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlashHistoryList>(create);
  static FlashHistoryList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FlashRecord> get records => $_getList(0);
}

class InstallPackRequest extends $pb.GeneratedMessage {
  factory InstallPackRequest({
    $core.String? packPath,
  }) {
    final result = create();
    if (packPath != null) result.packPath = packPath;
    return result;
  }

  InstallPackRequest._();

  factory InstallPackRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InstallPackRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InstallPackRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'packPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InstallPackRequest clone() => InstallPackRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InstallPackRequest copyWith(void Function(InstallPackRequest) updates) =>
      super.copyWith((message) => updates(message as InstallPackRequest))
          as InstallPackRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InstallPackRequest create() => InstallPackRequest._();
  @$core.override
  InstallPackRequest createEmptyInstance() => create();
  static $pb.PbList<InstallPackRequest> createRepeated() =>
      $pb.PbList<InstallPackRequest>();
  @$core.pragma('dart2js:noInline')
  static InstallPackRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InstallPackRequest>(create);
  static InstallPackRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get packPath => $_getSZ(0);
  @$pb.TagNumber(1)
  set packPath($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackPath() => $_clearField(1);
}

class InstalledPack extends $pb.GeneratedMessage {
  factory InstalledPack({
    $core.String? name,
    $core.String? vendor,
    $core.String? version,
    $core.Iterable<$core.String>? supportedChips,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (vendor != null) result.vendor = vendor;
    if (version != null) result.version = version;
    if (supportedChips != null) result.supportedChips.addAll(supportedChips);
    return result;
  }

  InstalledPack._();

  factory InstalledPack.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InstalledPack.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InstalledPack',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'vendor')
    ..aOS(3, _omitFieldNames ? '' : 'version')
    ..pPS(4, _omitFieldNames ? '' : 'supportedChips')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InstalledPack clone() => InstalledPack()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InstalledPack copyWith(void Function(InstalledPack) updates) =>
      super.copyWith((message) => updates(message as InstalledPack))
          as InstalledPack;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InstalledPack create() => InstalledPack._();
  @$core.override
  InstalledPack createEmptyInstance() => create();
  static $pb.PbList<InstalledPack> createRepeated() =>
      $pb.PbList<InstalledPack>();
  @$core.pragma('dart2js:noInline')
  static InstalledPack getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InstalledPack>(create);
  static InstalledPack? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get vendor => $_getSZ(1);
  @$pb.TagNumber(2)
  set vendor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVendor() => $_has(1);
  @$pb.TagNumber(2)
  void clearVendor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get version => $_getSZ(2);
  @$pb.TagNumber(3)
  set version($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get supportedChips => $_getList(3);
}

class InstalledPackList extends $pb.GeneratedMessage {
  factory InstalledPackList({
    $core.Iterable<InstalledPack>? packs,
  }) {
    final result = create();
    if (packs != null) result.packs.addAll(packs);
    return result;
  }

  InstalledPackList._();

  factory InstalledPackList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InstalledPackList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InstalledPackList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..pc<InstalledPack>(1, _omitFieldNames ? '' : 'packs', $pb.PbFieldType.PM,
        subBuilder: InstalledPack.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InstalledPackList clone() => InstalledPackList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InstalledPackList copyWith(void Function(InstalledPackList) updates) =>
      super.copyWith((message) => updates(message as InstalledPackList))
          as InstalledPackList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InstalledPackList create() => InstalledPackList._();
  @$core.override
  InstalledPackList createEmptyInstance() => create();
  static $pb.PbList<InstalledPackList> createRepeated() =>
      $pb.PbList<InstalledPackList>();
  @$core.pragma('dart2js:noInline')
  static InstalledPackList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InstalledPackList>(create);
  static InstalledPackList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InstalledPack> get packs => $_getList(0);
}

class GetProbeDetailsRequest extends $pb.GeneratedMessage {
  factory GetProbeDetailsRequest({
    $core.String? probeId,
  }) {
    final result = create();
    if (probeId != null) result.probeId = probeId;
    return result;
  }

  GetProbeDetailsRequest._();

  factory GetProbeDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProbeDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProbeDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'probeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProbeDetailsRequest clone() =>
      GetProbeDetailsRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProbeDetailsRequest copyWith(
          void Function(GetProbeDetailsRequest) updates) =>
      super.copyWith((message) => updates(message as GetProbeDetailsRequest))
          as GetProbeDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProbeDetailsRequest create() => GetProbeDetailsRequest._();
  @$core.override
  GetProbeDetailsRequest createEmptyInstance() => create();
  static $pb.PbList<GetProbeDetailsRequest> createRepeated() =>
      $pb.PbList<GetProbeDetailsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetProbeDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProbeDetailsRequest>(create);
  static GetProbeDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get probeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set probeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProbeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProbeId() => $_clearField(1);
}

class ProbeDetails extends $pb.GeneratedMessage {
  factory ProbeDetails({
    $core.String? id,
    $core.String? name,
    $core.String? vendor,
    $core.String? serialNumber,
    $core.String? firmwareVersion,
    $core.String? hardwareVersion,
    $core.double? targetVoltage,
    $core.bool? isConnected,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (vendor != null) result.vendor = vendor;
    if (serialNumber != null) result.serialNumber = serialNumber;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (hardwareVersion != null) result.hardwareVersion = hardwareVersion;
    if (targetVoltage != null) result.targetVoltage = targetVoltage;
    if (isConnected != null) result.isConnected = isConnected;
    return result;
  }

  ProbeDetails._();

  factory ProbeDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProbeDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProbeDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'vendor')
    ..aOS(4, _omitFieldNames ? '' : 'serialNumber')
    ..aOS(5, _omitFieldNames ? '' : 'firmwareVersion')
    ..aOS(6, _omitFieldNames ? '' : 'hardwareVersion')
    ..a<$core.double>(
        7, _omitFieldNames ? '' : 'targetVoltage', $pb.PbFieldType.OF)
    ..aOB(8, _omitFieldNames ? '' : 'isConnected')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProbeDetails clone() => ProbeDetails()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProbeDetails copyWith(void Function(ProbeDetails) updates) =>
      super.copyWith((message) => updates(message as ProbeDetails))
          as ProbeDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProbeDetails create() => ProbeDetails._();
  @$core.override
  ProbeDetails createEmptyInstance() => create();
  static $pb.PbList<ProbeDetails> createRepeated() =>
      $pb.PbList<ProbeDetails>();
  @$core.pragma('dart2js:noInline')
  static ProbeDetails getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProbeDetails>(create);
  static ProbeDetails? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get vendor => $_getSZ(2);
  @$pb.TagNumber(3)
  set vendor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVendor() => $_has(2);
  @$pb.TagNumber(3)
  void clearVendor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get serialNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set serialNumber($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSerialNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearSerialNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get firmwareVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set firmwareVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFirmwareVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearFirmwareVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get hardwareVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set hardwareVersion($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHardwareVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearHardwareVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get targetVoltage => $_getN(6);
  @$pb.TagNumber(7)
  set targetVoltage($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetVoltage() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetVoltage() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isConnected => $_getBF(7);
  @$pb.TagNumber(8)
  set isConnected($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsConnected() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsConnected() => $_clearField(8);
}

class ResetRequest extends $pb.GeneratedMessage {
  factory ResetRequest({
    ResetRequest_ResetType? type,
  }) {
    final result = create();
    if (type != null) result.type = type;
    return result;
  }

  ResetRequest._();

  factory ResetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..e<ResetRequest_ResetType>(
        1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: ResetRequest_ResetType.SOFTWARE,
        valueOf: ResetRequest_ResetType.valueOf,
        enumValues: ResetRequest_ResetType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetRequest clone() => ResetRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResetRequest copyWith(void Function(ResetRequest) updates) =>
      super.copyWith((message) => updates(message as ResetRequest))
          as ResetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResetRequest create() => ResetRequest._();
  @$core.override
  ResetRequest createEmptyInstance() => create();
  static $pb.PbList<ResetRequest> createRepeated() =>
      $pb.PbList<ResetRequest>();
  @$core.pragma('dart2js:noInline')
  static ResetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResetRequest>(create);
  static ResetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ResetRequest_ResetType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ResetRequest_ResetType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);
}

class PreviewRequest extends $pb.GeneratedMessage {
  factory PreviewRequest({
    $core.String? filePath,
    $fixnum.Int64? offset,
    $core.int? length,
  }) {
    final result = create();
    if (filePath != null) result.filePath = filePath;
    if (offset != null) result.offset = offset;
    if (length != null) result.length = length;
    return result;
  }

  PreviewRequest._();

  factory PreviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PreviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PreviewRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filePath')
    ..aInt64(2, _omitFieldNames ? '' : 'offset')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'length', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewRequest clone() => PreviewRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewRequest copyWith(void Function(PreviewRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewRequest))
          as PreviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PreviewRequest create() => PreviewRequest._();
  @$core.override
  PreviewRequest createEmptyInstance() => create();
  static $pb.PbList<PreviewRequest> createRepeated() =>
      $pb.PbList<PreviewRequest>();
  @$core.pragma('dart2js:noInline')
  static PreviewRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewRequest>(create);
  static PreviewRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filePath => $_getSZ(0);
  @$pb.TagNumber(1)
  set filePath($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilePath() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilePath() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(2)
  set offset($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get length => $_getIZ(2);
  @$pb.TagNumber(3)
  set length($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLength() => $_has(2);
  @$pb.TagNumber(3)
  void clearLength() => $_clearField(3);
}

class PreviewResponse extends $pb.GeneratedMessage {
  factory PreviewResponse({
    $core.String? hexDump,
    $fixnum.Int64? totalSize,
    $core.String? fileFormat,
  }) {
    final result = create();
    if (hexDump != null) result.hexDump = hexDump;
    if (totalSize != null) result.totalSize = totalSize;
    if (fileFormat != null) result.fileFormat = fileFormat;
    return result;
  }

  PreviewResponse._();

  factory PreviewResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PreviewResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PreviewResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hexDump')
    ..aInt64(2, _omitFieldNames ? '' : 'totalSize')
    ..aOS(3, _omitFieldNames ? '' : 'fileFormat')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewResponse clone() => PreviewResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewResponse copyWith(void Function(PreviewResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewResponse))
          as PreviewResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PreviewResponse create() => PreviewResponse._();
  @$core.override
  PreviewResponse createEmptyInstance() => create();
  static $pb.PbList<PreviewResponse> createRepeated() =>
      $pb.PbList<PreviewResponse>();
  @$core.pragma('dart2js:noInline')
  static PreviewResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewResponse>(create);
  static PreviewResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hexDump => $_getSZ(0);
  @$pb.TagNumber(1)
  set hexDump($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHexDump() => $_has(0);
  @$pb.TagNumber(1)
  void clearHexDump() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalSize => $_getI64(1);
  @$pb.TagNumber(2)
  set totalSize($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileFormat => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileFormat($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileFormat() => $_clearField(3);
}

class FileInfo extends $pb.GeneratedMessage {
  factory FileInfo({
    $core.String? format,
    $fixnum.Int64? totalSize,
    $fixnum.Int64? baseAddress,
  }) {
    final result = create();
    if (format != null) result.format = format;
    if (totalSize != null) result.totalSize = totalSize;
    if (baseAddress != null) result.baseAddress = baseAddress;
    return result;
  }

  FileInfo._();

  factory FileInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'format')
    ..aInt64(2, _omitFieldNames ? '' : 'totalSize')
    ..aInt64(3, _omitFieldNames ? '' : 'baseAddress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo clone() => FileInfo()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo copyWith(void Function(FileInfo) updates) =>
      super.copyWith((message) => updates(message as FileInfo)) as FileInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileInfo create() => FileInfo._();
  @$core.override
  FileInfo createEmptyInstance() => create();
  static $pb.PbList<FileInfo> createRepeated() => $pb.PbList<FileInfo>();
  @$core.pragma('dart2js:noInline')
  static FileInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileInfo>(create);
  static FileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get format => $_getSZ(0);
  @$pb.TagNumber(1)
  set format($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFormat() => $_has(0);
  @$pb.TagNumber(1)
  void clearFormat() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalSize => $_getI64(1);
  @$pb.TagNumber(2)
  set totalSize($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get baseAddress => $_getI64(2);
  @$pb.TagNumber(3)
  set baseAddress($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBaseAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearBaseAddress() => $_clearField(3);
}

/// Empty request/response messages
class ListProbesRequest extends $pb.GeneratedMessage {
  factory ListProbesRequest() => create();

  ListProbesRequest._();

  factory ListProbesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProbesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProbesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProbesRequest clone() => ListProbesRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProbesRequest copyWith(void Function(ListProbesRequest) updates) =>
      super.copyWith((message) => updates(message as ListProbesRequest))
          as ListProbesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProbesRequest create() => ListProbesRequest._();
  @$core.override
  ListProbesRequest createEmptyInstance() => create();
  static $pb.PbList<ListProbesRequest> createRepeated() =>
      $pb.PbList<ListProbesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListProbesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProbesRequest>(create);
  static ListProbesRequest? _defaultInstance;
}

class DisconnectProbeRequest extends $pb.GeneratedMessage {
  factory DisconnectProbeRequest() => create();

  DisconnectProbeRequest._();

  factory DisconnectProbeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisconnectProbeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisconnectProbeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectProbeRequest clone() =>
      DisconnectProbeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectProbeRequest copyWith(
          void Function(DisconnectProbeRequest) updates) =>
      super.copyWith((message) => updates(message as DisconnectProbeRequest))
          as DisconnectProbeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisconnectProbeRequest create() => DisconnectProbeRequest._();
  @$core.override
  DisconnectProbeRequest createEmptyInstance() => create();
  static $pb.PbList<DisconnectProbeRequest> createRepeated() =>
      $pb.PbList<DisconnectProbeRequest>();
  @$core.pragma('dart2js:noInline')
  static DisconnectProbeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisconnectProbeRequest>(create);
  static DisconnectProbeRequest? _defaultInstance;
}

class DisconnectProbeResponse extends $pb.GeneratedMessage {
  factory DisconnectProbeResponse() => create();

  DisconnectProbeResponse._();

  factory DisconnectProbeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisconnectProbeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisconnectProbeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectProbeResponse clone() =>
      DisconnectProbeResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisconnectProbeResponse copyWith(
          void Function(DisconnectProbeResponse) updates) =>
      super.copyWith((message) => updates(message as DisconnectProbeResponse))
          as DisconnectProbeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisconnectProbeResponse create() => DisconnectProbeResponse._();
  @$core.override
  DisconnectProbeResponse createEmptyInstance() => create();
  static $pb.PbList<DisconnectProbeResponse> createRepeated() =>
      $pb.PbList<DisconnectProbeResponse>();
  @$core.pragma('dart2js:noInline')
  static DisconnectProbeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisconnectProbeResponse>(create);
  static DisconnectProbeResponse? _defaultInstance;
}

class ReadChipIdRequest extends $pb.GeneratedMessage {
  factory ReadChipIdRequest() => create();

  ReadChipIdRequest._();

  factory ReadChipIdRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadChipIdRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadChipIdRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadChipIdRequest clone() => ReadChipIdRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadChipIdRequest copyWith(void Function(ReadChipIdRequest) updates) =>
      super.copyWith((message) => updates(message as ReadChipIdRequest))
          as ReadChipIdRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadChipIdRequest create() => ReadChipIdRequest._();
  @$core.override
  ReadChipIdRequest createEmptyInstance() => create();
  static $pb.PbList<ReadChipIdRequest> createRepeated() =>
      $pb.PbList<ReadChipIdRequest>();
  @$core.pragma('dart2js:noInline')
  static ReadChipIdRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadChipIdRequest>(create);
  static ReadChipIdRequest? _defaultInstance;
}

class ListPacksRequest extends $pb.GeneratedMessage {
  factory ListPacksRequest() => create();

  ListPacksRequest._();

  factory ListPacksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPacksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPacksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPacksRequest clone() => ListPacksRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPacksRequest copyWith(void Function(ListPacksRequest) updates) =>
      super.copyWith((message) => updates(message as ListPacksRequest))
          as ListPacksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPacksRequest create() => ListPacksRequest._();
  @$core.override
  ListPacksRequest createEmptyInstance() => create();
  static $pb.PbList<ListPacksRequest> createRepeated() =>
      $pb.PbList<ListPacksRequest>();
  @$core.pragma('dart2js:noInline')
  static ListPacksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPacksRequest>(create);
  static ListPacksRequest? _defaultInstance;
}

class ListInstalledPacksRequest extends $pb.GeneratedMessage {
  factory ListInstalledPacksRequest() => create();

  ListInstalledPacksRequest._();

  factory ListInstalledPacksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInstalledPacksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInstalledPacksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInstalledPacksRequest clone() =>
      ListInstalledPacksRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInstalledPacksRequest copyWith(
          void Function(ListInstalledPacksRequest) updates) =>
      super.copyWith((message) => updates(message as ListInstalledPacksRequest))
          as ListInstalledPacksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInstalledPacksRequest create() => ListInstalledPacksRequest._();
  @$core.override
  ListInstalledPacksRequest createEmptyInstance() => create();
  static $pb.PbList<ListInstalledPacksRequest> createRepeated() =>
      $pb.PbList<ListInstalledPacksRequest>();
  @$core.pragma('dart2js:noInline')
  static ListInstalledPacksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInstalledPacksRequest>(create);
  static ListInstalledPacksRequest? _defaultInstance;
}

class GetFlashHistoryRequest extends $pb.GeneratedMessage {
  factory GetFlashHistoryRequest() => create();

  GetFlashHistoryRequest._();

  factory GetFlashHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFlashHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFlashHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dap_flash'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlashHistoryRequest clone() =>
      GetFlashHistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlashHistoryRequest copyWith(
          void Function(GetFlashHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetFlashHistoryRequest))
          as GetFlashHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFlashHistoryRequest create() => GetFlashHistoryRequest._();
  @$core.override
  GetFlashHistoryRequest createEmptyInstance() => create();
  static $pb.PbList<GetFlashHistoryRequest> createRepeated() =>
      $pb.PbList<GetFlashHistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFlashHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFlashHistoryRequest>(create);
  static GetFlashHistoryRequest? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
