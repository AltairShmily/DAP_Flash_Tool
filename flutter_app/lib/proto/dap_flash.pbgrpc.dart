// This is a generated file - do not edit.
//
// Generated from dap_flash.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'dap_flash.pb.dart' as $0;

export 'dap_flash.pb.dart';

@$pb.GrpcServiceName('dap_flash.DapFlashService')
class DapFlashServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DapFlashServiceClient(super.channel, {super.options, super.interceptors});

  /// Device management
  $grpc.ResponseFuture<$0.ProbeList> listProbes(
    $0.ListProbesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProbes, request, options: options);
  }

  $grpc.ResponseFuture<$0.ConnectResponse> connectProbe(
    $0.ConnectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$connectProbe, request, options: options);
  }

  $grpc.ResponseFuture<$0.DisconnectProbeResponse> disconnectProbe(
    $0.DisconnectProbeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disconnectProbe, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProbeDetails> getProbeDetails(
    $0.GetProbeDetailsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getProbeDetails, request, options: options);
  }

  /// Flash operations (streaming progress)
  $grpc.ResponseStream<$0.ProgressUpdate> flashFirmware(
    $0.FlashRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$flashFirmware, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.ProgressUpdate> eraseChip(
    $0.EraseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$eraseChip, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.OperationResult> resetTarget(
    $0.ResetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resetTarget, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChipIdResult> readChipId(
    $0.ReadChipIdRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$readChipId, request, options: options);
  }

  /// Pack management
  $grpc.ResponseFuture<$0.PackList> listPacks(
    $0.ListPacksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPacks, request, options: options);
  }

  $grpc.ResponseFuture<$0.PackSearchResult> searchPacks(
    $0.SearchRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchPacks, request, options: options);
  }

  $grpc.ResponseStream<$0.ProgressUpdate> downloadPack(
    $0.DownloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$downloadPack, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.OperationResult> installPack(
    $0.InstallPackRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$installPack, request, options: options);
  }

  $grpc.ResponseFuture<$0.InstalledPackList> listInstalledPacks(
    $0.ListInstalledPacksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listInstalledPacks, request, options: options);
  }

  /// File preview
  $grpc.ResponseFuture<$0.PreviewResponse> previewFirmware(
    $0.PreviewRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$previewFirmware, request, options: options);
  }

  $grpc.ResponseFuture<$0.FileInfo> getFileInfo(
    $0.PreviewRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFileInfo, request, options: options);
  }

  /// History
  $grpc.ResponseFuture<$0.FlashHistoryList> getFlashHistory(
    $0.GetFlashHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFlashHistory, request, options: options);
  }

  // method descriptors

  static final _$listProbes =
      $grpc.ClientMethod<$0.ListProbesRequest, $0.ProbeList>(
          '/dap_flash.DapFlashService/ListProbes',
          ($0.ListProbesRequest value) => value.writeToBuffer(),
          $0.ProbeList.fromBuffer);
  static final _$connectProbe =
      $grpc.ClientMethod<$0.ConnectRequest, $0.ConnectResponse>(
          '/dap_flash.DapFlashService/ConnectProbe',
          ($0.ConnectRequest value) => value.writeToBuffer(),
          $0.ConnectResponse.fromBuffer);
  static final _$disconnectProbe =
      $grpc.ClientMethod<$0.DisconnectProbeRequest, $0.DisconnectProbeResponse>(
          '/dap_flash.DapFlashService/DisconnectProbe',
          ($0.DisconnectProbeRequest value) => value.writeToBuffer(),
          $0.DisconnectProbeResponse.fromBuffer);
  static final _$getProbeDetails =
      $grpc.ClientMethod<$0.GetProbeDetailsRequest, $0.ProbeDetails>(
          '/dap_flash.DapFlashService/GetProbeDetails',
          ($0.GetProbeDetailsRequest value) => value.writeToBuffer(),
          $0.ProbeDetails.fromBuffer);
  static final _$flashFirmware =
      $grpc.ClientMethod<$0.FlashRequest, $0.ProgressUpdate>(
          '/dap_flash.DapFlashService/FlashFirmware',
          ($0.FlashRequest value) => value.writeToBuffer(),
          $0.ProgressUpdate.fromBuffer);
  static final _$eraseChip =
      $grpc.ClientMethod<$0.EraseRequest, $0.ProgressUpdate>(
          '/dap_flash.DapFlashService/EraseChip',
          ($0.EraseRequest value) => value.writeToBuffer(),
          $0.ProgressUpdate.fromBuffer);
  static final _$resetTarget =
      $grpc.ClientMethod<$0.ResetRequest, $0.OperationResult>(
          '/dap_flash.DapFlashService/ResetTarget',
          ($0.ResetRequest value) => value.writeToBuffer(),
          $0.OperationResult.fromBuffer);
  static final _$readChipId =
      $grpc.ClientMethod<$0.ReadChipIdRequest, $0.ChipIdResult>(
          '/dap_flash.DapFlashService/ReadChipId',
          ($0.ReadChipIdRequest value) => value.writeToBuffer(),
          $0.ChipIdResult.fromBuffer);
  static final _$listPacks =
      $grpc.ClientMethod<$0.ListPacksRequest, $0.PackList>(
          '/dap_flash.DapFlashService/ListPacks',
          ($0.ListPacksRequest value) => value.writeToBuffer(),
          $0.PackList.fromBuffer);
  static final _$searchPacks =
      $grpc.ClientMethod<$0.SearchRequest, $0.PackSearchResult>(
          '/dap_flash.DapFlashService/SearchPacks',
          ($0.SearchRequest value) => value.writeToBuffer(),
          $0.PackSearchResult.fromBuffer);
  static final _$downloadPack =
      $grpc.ClientMethod<$0.DownloadRequest, $0.ProgressUpdate>(
          '/dap_flash.DapFlashService/DownloadPack',
          ($0.DownloadRequest value) => value.writeToBuffer(),
          $0.ProgressUpdate.fromBuffer);
  static final _$installPack =
      $grpc.ClientMethod<$0.InstallPackRequest, $0.OperationResult>(
          '/dap_flash.DapFlashService/InstallPack',
          ($0.InstallPackRequest value) => value.writeToBuffer(),
          $0.OperationResult.fromBuffer);
  static final _$listInstalledPacks =
      $grpc.ClientMethod<$0.ListInstalledPacksRequest, $0.InstalledPackList>(
          '/dap_flash.DapFlashService/ListInstalledPacks',
          ($0.ListInstalledPacksRequest value) => value.writeToBuffer(),
          $0.InstalledPackList.fromBuffer);
  static final _$previewFirmware =
      $grpc.ClientMethod<$0.PreviewRequest, $0.PreviewResponse>(
          '/dap_flash.DapFlashService/PreviewFirmware',
          ($0.PreviewRequest value) => value.writeToBuffer(),
          $0.PreviewResponse.fromBuffer);
  static final _$getFileInfo =
      $grpc.ClientMethod<$0.PreviewRequest, $0.FileInfo>(
          '/dap_flash.DapFlashService/GetFileInfo',
          ($0.PreviewRequest value) => value.writeToBuffer(),
          $0.FileInfo.fromBuffer);
  static final _$getFlashHistory =
      $grpc.ClientMethod<$0.GetFlashHistoryRequest, $0.FlashHistoryList>(
          '/dap_flash.DapFlashService/GetFlashHistory',
          ($0.GetFlashHistoryRequest value) => value.writeToBuffer(),
          $0.FlashHistoryList.fromBuffer);
}

@$pb.GrpcServiceName('dap_flash.DapFlashService')
abstract class DapFlashServiceBase extends $grpc.Service {
  $core.String get $name => 'dap_flash.DapFlashService';

  DapFlashServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListProbesRequest, $0.ProbeList>(
        'ListProbes',
        listProbes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListProbesRequest.fromBuffer(value),
        ($0.ProbeList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConnectRequest, $0.ConnectResponse>(
        'ConnectProbe',
        connectProbe_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConnectRequest.fromBuffer(value),
        ($0.ConnectResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DisconnectProbeRequest,
            $0.DisconnectProbeResponse>(
        'DisconnectProbe',
        disconnectProbe_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DisconnectProbeRequest.fromBuffer(value),
        ($0.DisconnectProbeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetProbeDetailsRequest, $0.ProbeDetails>(
        'GetProbeDetails',
        getProbeDetails_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetProbeDetailsRequest.fromBuffer(value),
        ($0.ProbeDetails value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FlashRequest, $0.ProgressUpdate>(
        'FlashFirmware',
        flashFirmware_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.FlashRequest.fromBuffer(value),
        ($0.ProgressUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EraseRequest, $0.ProgressUpdate>(
        'EraseChip',
        eraseChip_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.EraseRequest.fromBuffer(value),
        ($0.ProgressUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ResetRequest, $0.OperationResult>(
        'ResetTarget',
        resetTarget_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ResetRequest.fromBuffer(value),
        ($0.OperationResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReadChipIdRequest, $0.ChipIdResult>(
        'ReadChipId',
        readChipId_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ReadChipIdRequest.fromBuffer(value),
        ($0.ChipIdResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListPacksRequest, $0.PackList>(
        'ListPacks',
        listPacks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListPacksRequest.fromBuffer(value),
        ($0.PackList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchRequest, $0.PackSearchResult>(
        'SearchPacks',
        searchPacks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SearchRequest.fromBuffer(value),
        ($0.PackSearchResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DownloadRequest, $0.ProgressUpdate>(
        'DownloadPack',
        downloadPack_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.DownloadRequest.fromBuffer(value),
        ($0.ProgressUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InstallPackRequest, $0.OperationResult>(
        'InstallPack',
        installPack_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InstallPackRequest.fromBuffer(value),
        ($0.OperationResult value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListInstalledPacksRequest, $0.InstalledPackList>(
            'ListInstalledPacks',
            listInstalledPacks_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListInstalledPacksRequest.fromBuffer(value),
            ($0.InstalledPackList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PreviewRequest, $0.PreviewResponse>(
        'PreviewFirmware',
        previewFirmware_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PreviewRequest.fromBuffer(value),
        ($0.PreviewResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PreviewRequest, $0.FileInfo>(
        'GetFileInfo',
        getFileInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PreviewRequest.fromBuffer(value),
        ($0.FileInfo value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetFlashHistoryRequest, $0.FlashHistoryList>(
            'GetFlashHistory',
            getFlashHistory_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetFlashHistoryRequest.fromBuffer(value),
            ($0.FlashHistoryList value) => value.writeToBuffer()));
  }

  $async.Future<$0.ProbeList> listProbes_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListProbesRequest> $request) async {
    return listProbes($call, await $request);
  }

  $async.Future<$0.ProbeList> listProbes(
      $grpc.ServiceCall call, $0.ListProbesRequest request);

  $async.Future<$0.ConnectResponse> connectProbe_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ConnectRequest> $request) async {
    return connectProbe($call, await $request);
  }

  $async.Future<$0.ConnectResponse> connectProbe(
      $grpc.ServiceCall call, $0.ConnectRequest request);

  $async.Future<$0.DisconnectProbeResponse> disconnectProbe_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DisconnectProbeRequest> $request) async {
    return disconnectProbe($call, await $request);
  }

  $async.Future<$0.DisconnectProbeResponse> disconnectProbe(
      $grpc.ServiceCall call, $0.DisconnectProbeRequest request);

  $async.Future<$0.ProbeDetails> getProbeDetails_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetProbeDetailsRequest> $request) async {
    return getProbeDetails($call, await $request);
  }

  $async.Future<$0.ProbeDetails> getProbeDetails(
      $grpc.ServiceCall call, $0.GetProbeDetailsRequest request);

  $async.Stream<$0.ProgressUpdate> flashFirmware_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.FlashRequest> $request) async* {
    yield* flashFirmware($call, await $request);
  }

  $async.Stream<$0.ProgressUpdate> flashFirmware(
      $grpc.ServiceCall call, $0.FlashRequest request);

  $async.Stream<$0.ProgressUpdate> eraseChip_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.EraseRequest> $request) async* {
    yield* eraseChip($call, await $request);
  }

  $async.Stream<$0.ProgressUpdate> eraseChip(
      $grpc.ServiceCall call, $0.EraseRequest request);

  $async.Future<$0.OperationResult> resetTarget_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ResetRequest> $request) async {
    return resetTarget($call, await $request);
  }

  $async.Future<$0.OperationResult> resetTarget(
      $grpc.ServiceCall call, $0.ResetRequest request);

  $async.Future<$0.ChipIdResult> readChipId_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ReadChipIdRequest> $request) async {
    return readChipId($call, await $request);
  }

  $async.Future<$0.ChipIdResult> readChipId(
      $grpc.ServiceCall call, $0.ReadChipIdRequest request);

  $async.Future<$0.PackList> listPacks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListPacksRequest> $request) async {
    return listPacks($call, await $request);
  }

  $async.Future<$0.PackList> listPacks(
      $grpc.ServiceCall call, $0.ListPacksRequest request);

  $async.Future<$0.PackSearchResult> searchPacks_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SearchRequest> $request) async {
    return searchPacks($call, await $request);
  }

  $async.Future<$0.PackSearchResult> searchPacks(
      $grpc.ServiceCall call, $0.SearchRequest request);

  $async.Stream<$0.ProgressUpdate> downloadPack_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DownloadRequest> $request) async* {
    yield* downloadPack($call, await $request);
  }

  $async.Stream<$0.ProgressUpdate> downloadPack(
      $grpc.ServiceCall call, $0.DownloadRequest request);

  $async.Future<$0.OperationResult> installPack_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InstallPackRequest> $request) async {
    return installPack($call, await $request);
  }

  $async.Future<$0.OperationResult> installPack(
      $grpc.ServiceCall call, $0.InstallPackRequest request);

  $async.Future<$0.InstalledPackList> listInstalledPacks_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListInstalledPacksRequest> $request) async {
    return listInstalledPacks($call, await $request);
  }

  $async.Future<$0.InstalledPackList> listInstalledPacks(
      $grpc.ServiceCall call, $0.ListInstalledPacksRequest request);

  $async.Future<$0.PreviewResponse> previewFirmware_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PreviewRequest> $request) async {
    return previewFirmware($call, await $request);
  }

  $async.Future<$0.PreviewResponse> previewFirmware(
      $grpc.ServiceCall call, $0.PreviewRequest request);

  $async.Future<$0.FileInfo> getFileInfo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PreviewRequest> $request) async {
    return getFileInfo($call, await $request);
  }

  $async.Future<$0.FileInfo> getFileInfo(
      $grpc.ServiceCall call, $0.PreviewRequest request);

  $async.Future<$0.FlashHistoryList> getFlashHistory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetFlashHistoryRequest> $request) async {
    return getFlashHistory($call, await $request);
  }

  $async.Future<$0.FlashHistoryList> getFlashHistory(
      $grpc.ServiceCall call, $0.GetFlashHistoryRequest request);
}
