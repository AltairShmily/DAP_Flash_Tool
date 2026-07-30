import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackState {
  final List<String> availablePacks;
  final String? selectedPack;
  final List<String> availableChips;
  final String? selectedChip;
  final bool isLoading;

  const PackState({
    this.availablePacks = const [],
    this.selectedPack,
    this.availableChips = const [],
    this.selectedChip,
    this.isLoading = false,
  });

  PackState copyWith({
    List<String>? availablePacks,
    String? selectedPack,
    List<String>? availableChips,
    String? selectedChip,
    bool? isLoading,
  }) {
    return PackState(
      availablePacks: availablePacks ?? this.availablePacks,
      selectedPack: selectedPack ?? this.selectedPack,
      availableChips: availableChips ?? this.availableChips,
      selectedChip: selectedChip ?? this.selectedChip,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PackNotifier extends StateNotifier<PackState> {
  PackNotifier() : super(const PackState());

  void setPacks(List<String> packs) {
    state = state.copyWith(availablePacks: packs);
  }

  void selectPack(String pack) {
    state = state.copyWith(selectedPack: pack);
  }

  void setChips(List<String> chips) {
    state = state.copyWith(availableChips: chips);
  }

  void selectChip(String chip) {
    state = state.copyWith(selectedChip: chip);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final packProvider = StateNotifierProvider<PackNotifier, PackState>(
  (ref) => PackNotifier(),
);
