import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../proto/dap_flash.pb.dart';
import '../services/pack_service.dart';

class PackState {
  final List<PackInfo> packs;
  final List<PackInfo> searchResults;
  final String? selectedPack;
  final List<String> availableChips;
  final String? selectedChip;
  final bool isLoading;
  final bool isSearching;
  final bool isDownloading;
  final double downloadProgress;
  final String? errorMessage;

  const PackState({
    this.packs = const [],
    this.searchResults = const [],
    this.selectedPack,
    this.availableChips = const [],
    this.selectedChip,
    this.isLoading = false,
    this.isSearching = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.errorMessage,
  });

  PackState copyWith({
    List<PackInfo>? packs,
    List<PackInfo>? searchResults,
    String? selectedPack,
    bool clearSelectedPack = false,
    List<String>? availableChips,
    String? selectedChip,
    bool clearSelectedChip = false,
    bool? isLoading,
    bool? isSearching,
    bool? isDownloading,
    double? downloadProgress,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PackState(
      packs: packs ?? this.packs,
      searchResults: searchResults ?? this.searchResults,
      selectedPack: clearSelectedPack ? null : (selectedPack ?? this.selectedPack),
      availableChips: availableChips ?? this.availableChips,
      selectedChip: clearSelectedChip ? null : (selectedChip ?? this.selectedChip),
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PackNotifier extends StateNotifier<PackState> {
  final PackService _service = PackService();

  PackNotifier() : super(const PackState());

  Future<void> loadPacks() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final packs = await _service.listPacks();
      state = state.copyWith(packs: packs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load packs: $e',
      );
    }
  }

  Future<void> searchPacks(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], clearError: true);
      return;
    }
    state = state.copyWith(isSearching: true, clearError: true);
    try {
      final results = await _service.searchPacks(query);
      state = state.copyWith(searchResults: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Search failed: $e',
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(searchResults: [], clearError: true);
  }

  Future<void> downloadPack(String packUrl, String packName) async {
    state = state.copyWith(isDownloading: true, downloadProgress: 0.0, clearError: true);
    try {
      await for (final update in _service.downloadPack(
        packUrl: packUrl,
        packName: packName,
      )) {
        state = state.copyWith(
          downloadProgress: update.progress.clamp(0.0, 1.0),
        );
      }
      state = state.copyWith(isDownloading: false, downloadProgress: 1.0);
      // Auto-refresh pack list after download completes
      await loadPacks();
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        errorMessage: 'Download failed: $e',
      );
    }
  }

  void selectPack(String name) {
    final pack = state.packs.firstWhere(
      (p) => p.name == name,
      orElse: () => state.searchResults.firstWhere(
        (p) => p.name == name,
        orElse: () => PackInfo(),
      ),
    );
    state = state.copyWith(
      selectedPack: name,
      availableChips: pack.supportedChips,
      clearSelectedChip: true,
    );
  }

  void selectChip(String chip) {
    state = state.copyWith(selectedChip: chip);
  }
}

final packProvider = StateNotifierProvider<PackNotifier, PackState>(
  (ref) => PackNotifier(),
);
