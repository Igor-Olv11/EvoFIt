import 'package:flutter/material.dart';

import '../models/avaliacao.dart';
import '../services/storage_service.dart';

class NovaAvaliacaoScreen extends StatefulWidget {
  final StorageService storage;

  const NovaAvaliacaoScreen({super.key, required this.storage});

  @override
  State<NovaAvaliacaoScreen> createState() => _NovaAvaliacaoScreenState();
}

class _NovaAvaliacaoScreenState extends State<NovaAvaliacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  static const _fields = <String, String>{
    'peso': 'Peso (kg) *',
    'altura': 'Altura (cm)',
    'gordura': '% de gordura',
    'massaMuscular': 'Massa muscular (kg)',
    'massaMagra': 'Massa magra (kg)',
    'gorduraVisceral': 'Gordura visceral',
    'idadeMetabolica': 'Idade metabólica',
    'pescoco': 'Pescoço (cm)',
    'ombros': 'Ombros (cm)',
    'peito': 'Peito (cm)',
    'cintura': 'Cintura (cm)',
    'abdomen': 'Abdômen (cm)',
    'quadril': 'Quadril (cm)',
    'bracoDireitoRelaxado': 'Braço direito relaxado (cm)',
    'bracoDireitoContraido': 'Braço direito contraído (cm)',
    'bracoEsquerdoRelaxado': 'Braço esquerdo relaxado (cm)',
    'bracoEsquerdoContraido': 'Braço esquerdo contraído (cm)',
    'antebracoDireito': 'Antebraço direito (cm)',
    'antebracoEsquerdo': 'Antebraço esquerdo (cm)',
    'coxaDireita': 'Coxa direita (cm)',
    'coxaEsquerda': 'Coxa esquerda (cm)',
    'panturrilhaDireita': 'Panturrilha direita (cm)',
    'panturrilhaEsquerda': 'Panturrilha esquerda (cm)',
    'joelhoDireito': 'Joelho direito (cm)',
    'joelhoEsquerdo': 'Joelho esquerdo (cm)',
  };

  static const _tronco = [
    'pescoco',
    'ombros',
    'peito',
    'cintura',
    'abdomen',
    'quadril',
  ];

  static const _bracos = [
    'bracoDireitoRelaxado',
    'bracoDireitoContraido',
    'bracoEsquerdoRelaxado',
    'bracoEsquerdoContraido',
  ];

  static const _antebracos = [
    'antebracoDireito',
    'antebracoEsquerdo',
  ];

  static const _pernas = [
    'coxaDireita',
    'coxaEsquerda',
    'panturrilhaDireita',
    'panturrilhaEsquerda',
    'joelhoDireito',
    'joelhoEsquerdo',
  ];

  @override
  void initState() {
    super.initState();
    for (final key in _fields.keys) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _observacoes.dispose();
    super.dispose();
  }

  double? _parse(String key) {
    final text = _controllers[key]!.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  TextEditingController _c(String key) => _controllers[key]!;

  String? _validateNumber(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Obrigatório' : null;
    }
    final n = double.tryParse(value.replaceAll(',', '.'));
    if (n == null || n <= 0) return 'Valor inválido';
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final peso = _parse('peso');
    if (peso == null || peso <= 0) return;

    setState(() => _saving = true);

    final avaliacao = Avaliacao(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      data: DateTime.now(),
      peso: peso,
      altura: _parse('altura'),
      gordura: _parse('gordura'),
      massaMuscular: _parse('massaMuscular'),
      massaMagra: _parse('massaMagra'),
      gorduraVisceral: _parse('gorduraVisceral'),
      idadeMetabolica: _parse('idadeMetabolica'),
      pescoco: _parse('pescoco'),
      ombros: _parse('ombros'),
      peito: _parse('peito'),
      cintura: _parse('cintura'),
      abdomen: _parse('abdomen'),
      quadril: _parse('quadril'),
      bracoDireitoRelaxado: _parse('bracoDireitoRelaxado'),
      bracoDireitoContraido: _parse('bracoDireitoContraido'),
      bracoEsquerdoRelaxado: _parse('bracoEsquerdoRelaxado'),
      bracoEsquerdoContraido: _parse('bracoEsquerdoContraido'),
      antebracoDireito: _parse('antebracoDireito'),
      antebracoEsquerdo: _parse('antebracoEsquerdo'),
      coxaDireita: _parse('coxaDireita'),
      coxaEsquerda: _parse('coxaEsquerda'),
      panturrilhaDireita: _parse('panturrilhaDireita'),
      panturrilhaEsquerda: _parse('panturrilhaEsquerda'),
      joelhoDireito: _parse('joelhoDireito'),
      joelhoEsquerdo: _parse('joelhoEsquerdo'),
      observacoes: _observacoes.text.trim(),
    );

    await widget.storage.salvarAvaliacao(avaliacao);

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação salva com sucesso.')),
    );
    Navigator.pop(context, true);
  }

  final _observacoes = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova avaliação'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Color(0xFF2196F3)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data e horário serão registrados automaticamente no momento do salvamento.',
                        style: TextStyle(color: Colors.white.withOpacity(.7)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _Section(title: 'Dados gerais', keys: [
              'peso',
              'altura',
              'gordura',
              'massaMuscular',
              'massaMagra',
              'gorduraVisceral',
              'idadeMetabolica',
            ]),
            const SizedBox(height: 22),
            _Section(title: 'Tronco', keys: _tronco),
            const SizedBox(height: 22),
            _Section(title: 'Braços', keys: _bracos),
            const SizedBox(height: 22),
            _Section(title: 'Antebraços', keys: _antebracos),
            const SizedBox(height: 22),
            _Section(title: 'Pernas', keys: _pernas),
            const SizedBox(height: 22),
            Text(
              'Observações',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacoes,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex.: comecei nova dieta, medi pela manhã...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _saving ? null : _salvar,
                icon: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'SALVANDO...' : 'SALVAR AVALIAÇÃO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> keys;

  const _Section({required this.title, required this.keys});

  String _label(String key) {
    const labels = _NovaAvaliacaoScreenState._fields;
    return labels[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_NovaAvaliacaoScreenState>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 620 ? 2 : 1;
            if (columns == 1) {
              return Column(
                children: keys
                    .map((key) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _field(context, state, key),
                        ))
                    .toList(),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: keys
                  .map(
                    (key) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: _field(context, state, key),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context,
    _NovaAvaliacaoScreenState state,
    String key,
  ) {
    final required = key == 'peso';
    return TextFormField(
      controller: state._c(key),
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: _label(key),
        suffixText: key == 'peso' ||
                key == 'massaMuscular' ||
                key == 'massaMagra'
            ? 'kg'
            : key == 'gordura'
                ? '%'
                : null,
      ),
      validator: (value) =>
          state._validateNumber(value, required: required),
    );
  }
}
