import 'package:flutter/material.dart';

import '../models/perfil.dart';
import '../services/storage_service.dart';

class PerfilScreen extends StatefulWidget {
  final StorageService storage;
  final Perfil? perfilInicial;
  final bool embedded;
  final VoidCallback? onSaved;

  const PerfilScreen({
    super.key,
    required this.storage,
    this.perfilInicial,
    this.embedded = false,
    this.onSaved,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _altura;
  late final TextEditingController _peso;
  late final TextEditingController _pesoMeta;

  DateTime? _nascimento;
  String? _sexo;
  String _objetivo = 'Recomposição corporal';
  bool _saving = false;

  static const objetivos = [
    'Ganhar massa muscular',
    'Perder gordura',
    'Recomposição corporal',
    'Ganhar força',
    'Melhorar condicionamento',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.perfilInicial;
    _nome = TextEditingController(text: p?.nome ?? '');
    _altura = TextEditingController(text: _fmt(p?.altura));
    _peso = TextEditingController(text: _fmt(p?.peso));
    _pesoMeta = TextEditingController(text: _fmt(p?.pesoMeta));
    _nascimento = p?.dataNascimento;
    _sexo = p?.sexo;
    _objetivo = p?.objetivo != null && objetivos.contains(p!.objetivo)
        ? p.objetivo
        : 'Recomposição corporal';
  }

  static String _fmt(double? value) =>
      value == null ? '' : value.toStringAsFixed(1);

  @override
  void dispose() {
    _nome.dispose();
    _altura.dispose();
    _peso.dispose();
    _pesoMeta.dispose();
    super.dispose();
  }

  double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nascimento ?? DateTime(DateTime.now().year - 20),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _nascimento = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final peso = _parse(_peso.text);
    if (peso == null || peso <= 0) {
      _show('Informe um peso válido.');
      return;
    }

    setState(() => _saving = true);

    final perfil = Perfil(
      nome: _nome.text.trim(),
      dataNascimento: _nascimento,
      sexo: _sexo,
      altura: _parse(_altura.text),
      peso: peso,
      objetivo: _objetivo,
      pesoMeta: _parse(_pesoMeta.text),
    );

    await widget.storage.salvarPerfil(perfil);

    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSaved?.call();

    if (!widget.embedded) {
      Navigator.pop(context, true);
    } else {
      _show('Perfil salvo com sucesso.');
    }
  }

  void _show(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final body = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          if (!widget.embedded) ...[
            Text(
              'Seu perfil',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Esses dados ajudam o EvoFit a contextualizar sua evolução.',
              style: TextStyle(color: Colors.white.withOpacity(.6)),
            ),
            const SizedBox(height: 24),
          ],
          _SectionTitle(title: 'Dados pessoais'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nome,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Informe seu nome.' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.cake_outlined),
                  label: Text(
                    _nascimento == null
                        ? 'Data de nascimento'
                        : '${_nascimento!.day.toString().padLeft(2, '0')}/${_nascimento!.month.toString().padLeft(2, '0')}/${_nascimento!.year}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _sexo,
            decoration: const InputDecoration(
              labelText: 'Sexo',
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
              DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
              DropdownMenuItem(value: 'Outro', child: Text('Outro')),
              DropdownMenuItem(
                value: 'Prefiro não informar',
                child: Text('Prefiro não informar'),
              ),
            ],
            onChanged: (value) => setState(() => _sexo = value),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Objetivo'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _objetivo,
            decoration: const InputDecoration(
              labelText: 'Objetivo principal',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: objetivos
                .map((item) =>
                    DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _objetivo = value);
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Dados corporais'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _altura,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Altura (cm)',
                    suffixText: 'cm',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final n = _parse(value);
                    if (n == null || n <= 0) return 'Inválida';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _peso,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Peso atual',
                    suffixText: 'kg',
                  ),
                  validator: (value) {
                    final n = _parse(value ?? '');
                    if (n == null || n <= 0) return 'Informe o peso';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pesoMeta,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Peso meta',
              suffixText: 'kg',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final n = _parse(value);
              if (n == null || n <= 0) return 'Inválido';
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _saving ? null : _salvar,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'SALVANDO...' : 'SALVAR PERFIL'),
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Perfil',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(child: body),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
