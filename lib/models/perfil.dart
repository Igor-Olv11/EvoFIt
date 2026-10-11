class Perfil {
  final String nome;
  final DateTime? dataNascimento;
  final String? sexo;
  final double? altura;
  final double? peso;
  final String objetivo;
  final double? pesoMeta;

  const Perfil({
    required this.nome,
    this.dataNascimento,
    this.sexo,
    this.altura,
    this.peso,
    required this.objetivo,
    this.pesoMeta,
  });

  int? get idade {
    final nascimento = dataNascimento;
    if (nascimento == null) return null;

    final hoje = DateTime.now();
    var idade = hoje.year - nascimento.year;
    if (hoje.month < nascimento.month ||
        (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
      idade--;
    }
    return idade >= 0 ? idade : null;
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'dataNascimento': dataNascimento?.toIso8601String(),
        'sexo': sexo,
        'altura': altura,
        'peso': peso,
        'objetivo': objetivo,
        'pesoMeta': pesoMeta,
      };

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      nome: json['nome']?.toString() ?? '',
      dataNascimento: DateTime.tryParse(
        json['dataNascimento']?.toString() ?? '',
      ),
      sexo: json['sexo']?.toString(),
      altura: _toDouble(json['altura']),
      peso: _toDouble(json['peso']),
      objetivo: json['objetivo']?.toString() ?? 'Recomposição corporal',
      pesoMeta: _toDouble(json['pesoMeta']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }
}
