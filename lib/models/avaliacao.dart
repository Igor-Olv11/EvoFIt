class Avaliacao {
  final String id;
  final DateTime data;
  final double peso;
  final double? altura;
  final double? gordura;
  final double? massaMuscular;
  final double? massaMagra;
  final double? gorduraVisceral;
  final double? idadeMetabolica;
  final double? pescoco;
  final double? ombros;
  final double? peito;
  final double? cintura;
  final double? abdomen;
  final double? quadril;
  final double? bracoDireitoRelaxado;
  final double? bracoDireitoContraido;
  final double? bracoEsquerdoRelaxado;
  final double? bracoEsquerdoContraido;
  final double? antebracoDireito;
  final double? antebracoEsquerdo;
  final double? coxaDireita;
  final double? coxaEsquerda;
  final double? panturrilhaDireita;
  final double? panturrilhaEsquerda;
  final double? joelhoDireito;
  final double? joelhoEsquerdo;
  final String observacoes;

  const Avaliacao({
    required this.id,
    required this.data,
    required this.peso,
    this.altura,
    this.gordura,
    this.massaMuscular,
    this.massaMagra,
    this.gorduraVisceral,
    this.idadeMetabolica,
    this.pescoco,
    this.ombros,
    this.peito,
    this.cintura,
    this.abdomen,
    this.quadril,
    this.bracoDireitoRelaxado,
    this.bracoDireitoContraido,
    this.bracoEsquerdoRelaxado,
    this.bracoEsquerdoContraido,
    this.antebracoDireito,
    this.antebracoEsquerdo,
    this.coxaDireita,
    this.coxaEsquerda,
    this.panturrilhaDireita,
    this.panturrilhaEsquerda,
    this.joelhoDireito,
    this.joelhoEsquerdo,
    this.observacoes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data.toIso8601String(),
        'peso': peso,
        'altura': altura,
        'gordura': gordura,
        'massaMuscular': massaMuscular,
        'massaMagra': massaMagra,
        'gorduraVisceral': gorduraVisceral,
        'idadeMetabolica': idadeMetabolica,
        'pescoco': pescoco,
        'ombros': ombros,
        'peito': peito,
        'cintura': cintura,
        'abdomen': abdomen,
        'quadril': quadril,
        'bracoDireitoRelaxado': bracoDireitoRelaxado,
        'bracoDireitoContraido': bracoDireitoContraido,
        'bracoEsquerdoRelaxado': bracoEsquerdoRelaxado,
        'bracoEsquerdoContraido': bracoEsquerdoContraido,
        'antebracoDireito': antebracoDireito,
        'antebracoEsquerdo': antebracoEsquerdo,
        'coxaDireita': coxaDireita,
        'coxaEsquerda': coxaEsquerda,
        'panturrilhaDireita': panturrilhaDireita,
        'panturrilhaEsquerda': panturrilhaEsquerda,
        'joelhoDireito': joelhoDireito,
        'joelhoEsquerdo': joelhoEsquerdo,
        'observacoes': observacoes,
      };

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      peso: _toDouble(json['peso']) ?? 0,
      altura: _toDouble(json['altura']),
      gordura: _toDouble(json['gordura']),
      massaMuscular: _toDouble(json['massaMuscular']),
      massaMagra: _toDouble(json['massaMagra']),
      gorduraVisceral: _toDouble(json['gorduraVisceral']),
      idadeMetabolica: _toDouble(json['idadeMetabolica']),
      pescoco: _toDouble(json['pescoco']),
      ombros: _toDouble(json['ombros']),
      peito: _toDouble(json['peito']),
      cintura: _toDouble(json['cintura']),
      abdomen: _toDouble(json['abdomen']),
      quadril: _toDouble(json['quadril']),
      bracoDireitoRelaxado: _toDouble(json['bracoDireitoRelaxado']),
      bracoDireitoContraido: _toDouble(json['bracoDireitoContraido']),
      bracoEsquerdoRelaxado: _toDouble(json['bracoEsquerdoRelaxado']),
      bracoEsquerdoContraido: _toDouble(json['bracoEsquerdoContraido']),
      antebracoDireito: _toDouble(json['antebracoDireito']),
      antebracoEsquerdo: _toDouble(json['antebracoEsquerdo']),
      coxaDireita: _toDouble(json['coxaDireita']),
      coxaEsquerda: _toDouble(json['coxaEsquerda']),
      panturrilhaDireita: _toDouble(json['panturrilhaDireita']),
      panturrilhaEsquerda: _toDouble(json['panturrilhaEsquerda']),
      joelhoDireito: _toDouble(json['joelhoDireito']),
      joelhoEsquerdo: _toDouble(json['joelhoEsquerdo']),
      observacoes: json['observacoes']?.toString() ?? '',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }
}
