import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/perfil.dart';
import '../models/avaliacao.dart';

class StorageService {
  static const _perfilKey = 'evofit_perfil';
  static const _avaliacoesKey = 'evofit_avaliacoes';

  final SharedPreferences prefs;

  StorageService(this.prefs);

  Future<void> salvarPerfil(Perfil perfil) async {
    await prefs.setString(_perfilKey, jsonEncode(perfil.toJson()));
  }

  Future<Perfil?> carregarPerfil() async {
    final raw = prefs.getString(_perfilKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      return Perfil.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<void> salvarAvaliacao(Avaliacao avaliacao) async {
    final avaliacoes = await carregarAvaliacoes();
    avaliacoes.removeWhere((item) => item.id == avaliacao.id);
    avaliacoes.add(avaliacao);
    avaliacoes.sort((a, b) => b.data.compareTo(a.data));

    await prefs.setString(
      _avaliacoesKey,
      jsonEncode(avaliacoes.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<Avaliacao>> carregarAvaliacoes() async {
    final raw = prefs.getString(_avaliacoesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final result = <Avaliacao>[];
      for (final item in decoded) {
        if (item is Map) {
          final avaliacao =
              Avaliacao.fromJson(Map<String, dynamic>.from(item));
          if (avaliacao.peso > 0) result.add(avaliacao);
        }
      }

      result.sort((a, b) => b.data.compareTo(a.data));
      return result;
    } catch (_) {
      return [];
    }
  }

  Future<void> excluirAvaliacao(String id) async {
    final avaliacoes = await carregarAvaliacoes();
    avaliacoes.removeWhere((item) => item.id == id);

    await prefs.setString(
      _avaliacoesKey,
      jsonEncode(avaliacoes.map((e) => e.toJson()).toList()),
    );
  }
}
