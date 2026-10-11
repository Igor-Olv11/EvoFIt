import 'package:flutter/material.dart';

import '../models/avaliacao.dart';
import '../models/perfil.dart';
import '../services/storage_service.dart';

class HistoricoScreen extends StatefulWidget {
  final StorageService storage;
  final Perfil? perfil;
  final List<Avaliacao> avaliacoes;
  final Future<void> Function() onChanged;

  const HistoricoScreen({
    super.key,
    required this.storage,
    required this.perfil,
    required this.avaliacoes,
    required this.onChanged,
  });

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  int? _selectedA;
  int? _selectedB;

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.avaliacoes]
      ..sort((a, b) => b.data.compareTo(a.data));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Evolução',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          if (sorted.length >= 2)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _ComparisonCard(
                  evaluations: sorted,
                  selectedA: _selectedA,
                  selectedB: _selectedB,
                  onA: (value) => setState(() => _selectedA = value),
                  onB: (value) => setState(() => _selectedB = value),
                  onCompare: () {
                    if (_selectedA == null || _selectedB == null) {
                      _show('Selecione as duas avaliações.');
                      return;
                    }
                    if (_selectedA == _selectedB) {
                      _show('Escolha avaliações diferentes.');
                      return;
                    }

                    final older =
                        sorted[_selectedA!].data.isBefore(sorted[_selectedB!].data)
                            ? sorted[_selectedA!]
                            : sorted[_selectedB!];
                    final newer =
                        identical(older, sorted[_selectedA!])
                            ? sorted[_selectedB!]
                            : sorted[_selectedA!];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComparisonScreen(
                          anterior: older,
                          atual: newer,
                          perfil: widget.perfil,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (sorted.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyHistory(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              sliver: SliverList.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final item = sorted[index];
                  return _EvaluationTile(
                    evaluation: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EvaluationDetailScreen(
                          evaluation: item,
                          storage: widget.storage,
                          onChanged: widget.onChanged,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insights_outlined,
              size: 56,
              color: Color(0xFF2196F3),
            ),
            const SizedBox(height: 18),
            const Text(
              'Registre sua primeira avaliação',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Com duas ou mais avaliações, você poderá comparar sua evolução.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final List<Avaliacao> evaluations;
  final int? selectedA;
  final int? selectedB;
  final ValueChanged<int?> onA;
  final ValueChanged<int?> onB;
  final VoidCallback onCompare;

  const _ComparisonCard({
    required this.evaluations,
    required this.selectedA,
    required this.selectedB,
    required this.onA,
    required this.onB,
    required this.onCompare,
  });

  String _date(Avaliacao a) {
    final d = a.data;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparar avaliações',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedA,
              decoration: const InputDecoration(labelText: 'Avaliação 1'),
              items: List.generate(
                evaluations.length,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    '${_date(evaluations[i])} • ${evaluations[i].peso.toStringAsFixed(1)} kg',
                  ),
                ),
              ),
              onChanged: onA,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: selectedB,
              decoration: const InputDecoration(labelText: 'Avaliação 2'),
              items: List.generate(
                evaluations.length,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    '${_date(evaluations[i])} • ${evaluations[i].peso.toStringAsFixed(1)} kg',
                  ),
                ),
              ),
              onChanged: onB,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCompare,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('COMPARAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvaluationTile extends StatelessWidget {
  final Avaliacao evaluation;
  final VoidCallback onTap;

  const _EvaluationTile({
    required this.evaluation,
    required this.onTap,
  });

  String _date() {
    final d = evaluation.data;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x222196F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _date(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${evaluation.peso.toStringAsFixed(1)} kg'
                      '${evaluation.gordura == null ? '' : '  •  ${evaluation.gordura!.toStringAsFixed(1)}% gordura'}',
                      style: TextStyle(color: Colors.white.withOpacity(.62)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class EvaluationDetailScreen extends StatelessWidget {
  final Avaliacao evaluation;
  final StorageService storage;
  final Future<void> Function() onChanged;

  const EvaluationDetailScreen({
    super.key,
    required this.evaluation,
    required this.storage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fields = <String, double?>{
      'Peso (kg)': evaluation.peso,
      'Altura (cm)': evaluation.altura,
      'Gordura (%)': evaluation.gordura,
      'Massa muscular (kg)': evaluation.massaMuscular,
      'Massa magra (kg)': evaluation.massaMagra,
      'Gordura visceral': evaluation.gorduraVisceral,
      'Idade metabólica': evaluation.idadeMetabolica,
      'Pescoço (cm)': evaluation.pescoco,
      'Ombros (cm)': evaluation.ombros,
      'Peito (cm)': evaluation.peito,
      'Cintura (cm)': evaluation.cintura,
      'Abdômen (cm)': evaluation.abdomen,
      'Quadril (cm)': evaluation.quadril,
      'Braço direito relaxado (cm)': evaluation.bracoDireitoRelaxado,
      'Braço direito contraído (cm)': evaluation.bracoDireitoContraido,
      'Braço esquerdo relaxado (cm)': evaluation.bracoEsquerdoRelaxado,
      'Braço esquerdo contraído (cm)': evaluation.bracoEsquerdoContraido,
      'Antebraço direito (cm)': evaluation.antebracoDireito,
      'Antebraço esquerdo (cm)': evaluation.antebracoEsquerdo,
      'Coxa direita (cm)': evaluation.coxaDireita,
      'Coxa esquerda (cm)': evaluation.coxaEsquerda,
      'Panturrilha direita (cm)': evaluation.panturrilhaDireita,
      'Panturrilha esquerda (cm)': evaluation.panturrilhaEsquerda,
      'Joelho direito (cm)': evaluation.joelhoDireito,
      'Joelho esquerdo (cm)': evaluation.joelhoEsquerdo,
    };

    final d = evaluation.data;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Excluir avaliação?'),
                  content: const Text(
                    'Essa avaliação será removida permanentemente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;
              await storage.excluirAvaliacao(evaluation.id);
              await onChanged();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF2196F3)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(color: Colors.white.withOpacity(.6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _DetailSection(
            title: 'Dados da avaliação',
            fields: fields,
          ),
          if (evaluation.observacoes.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Observações',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      evaluation.observacoes,
                      style: TextStyle(color: Colors.white.withOpacity(.72)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Map<String, double?> fields;

  const _DetailSection({
    required this.title,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    final valid = fields.entries.where((e) => e.value != null).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...valid.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: TextStyle(color: Colors.white.withOpacity(.65)),
                      ),
                    ),
                    Text(
                      e.value!.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComparisonScreen extends StatelessWidget {
  final Avaliacao anterior;
  final Avaliacao atual;
  final Perfil? perfil;

  const ComparisonScreen({
    super.key,
    required this.anterior,
    required this.atual,
    required this.perfil,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = <String, _Pair>{
      'Peso (kg)': _Pair(anterior.peso, atual.peso),
      'Gordura (%)': _Pair(anterior.gordura, atual.gordura),
      'Massa muscular (kg)': _Pair(anterior.massaMuscular, atual.massaMuscular),
      'Massa magra (kg)': _Pair(anterior.massaMagra, atual.massaMagra),
      'Pescoço (cm)': _Pair(anterior.pescoco, atual.pescoco),
      'Ombros (cm)': _Pair(anterior.ombros, atual.ombros),
      'Peito (cm)': _Pair(anterior.peito, atual.peito),
      'Cintura (cm)': _Pair(anterior.cintura, atual.cintura),
      'Abdômen (cm)': _Pair(anterior.abdomen, atual.abdomen),
      'Quadril (cm)': _Pair(anterior.quadril, atual.quadril),
      'Braço direito relaxado (cm)':
          _Pair(anterior.bracoDireitoRelaxado, atual.bracoDireitoRelaxado),
      'Braço direito contraído (cm)':
          _Pair(anterior.bracoDireitoContraido, atual.bracoDireitoContraido),
      'Braço esquerdo relaxado (cm)':
          _Pair(anterior.bracoEsquerdoRelaxado, atual.bracoEsquerdoRelaxado),
      'Braço esquerdo contraído (cm)':
          _Pair(anterior.bracoEsquerdoContraido, atual.bracoEsquerdoContraido),
      'Antebraço direito (cm)':
          _Pair(anterior.antebracoDireito, atual.antebracoDireito),
      'Antebraço esquerdo (cm)':
          _Pair(anterior.antebracoEsquerdo, atual.antebracoEsquerdo),
      'Coxa direita (cm)': _Pair(anterior.coxaDireita, atual.coxaDireita),
      'Coxa esquerda (cm)': _Pair(anterior.coxaEsquerda, atual.coxaEsquerda),
      'Panturrilha direita (cm)':
          _Pair(anterior.panturrilhaDireita, atual.panturrilhaDireita),
      'Panturrilha esquerda (cm)':
          _Pair(anterior.panturrilhaEsquerda, atual.panturrilhaEsquerda),
      'Joelho direito (cm)': _Pair(anterior.joelhoDireito, atual.joelhoDireito),
      'Joelho esquerdo (cm)': _Pair(anterior.joelhoEsquerdo, atual.joelhoEsquerdo),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Comparação')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          _HeaderDates(anterior: anterior, atual: atual),
          const SizedBox(height: 18),
          ...metrics.entries
              .where((entry) => entry.value.hasData)
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ComparisonTile(
                      label: entry.key,
                      pair: entry.value,
                    ),
                  )),
        ],
      ),
    );
  }
}

class _HeaderDates extends StatelessWidget {
  final Avaliacao anterior;
  final Avaliacao atual;

  const _HeaderDates({required this.anterior, required this.atual});

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateBox(
            title: 'Anterior',
            date: _date(anterior.data),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, color: Color(0xFF2196F3)),
        ),
        Expanded(
          child: _DateBox(
            title: 'Atual',
            date: _date(atual.data),
          ),
        ),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String title;
  final String date;

  const _DateBox({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.white.withOpacity(.6))),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _Pair {
  final double? oldValue;
  final double? newValue;

  const _Pair(this.oldValue, this.newValue);

  bool get hasData => oldValue != null || newValue != null;

  double? get diff =>
      oldValue != null && newValue != null ? newValue! - oldValue! : null;
}

class _ComparisonTile extends StatelessWidget {
  final String label;
  final _Pair pair;

  const _ComparisonTile({required this.label, required this.pair});

  @override
  Widget build(BuildContext context) {
    final diff = pair.diff;
    final diffText = diff == null
        ? 'Sem comparação'
        : diff.abs() < 0.05
            ? 'Sem alteração'
            : '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}';

    final icon = diff == null
        ? Icons.remove
        : diff > 0.05
            ? Icons.arrow_upward
            : diff < -0.05
                ? Icons.arrow_downward
                : Icons.remove;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0x222196F3),
              child: Icon(icon, color: const Color(0xFF2196F3)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(
                    '${pair.oldValue?.toStringAsFixed(1) ?? '--'} → ${pair.newValue?.toStringAsFixed(1) ?? '--'}',
                    style: TextStyle(color: Colors.white.withOpacity(.62)),
                  ),
                ],
              ),
            ),
            Text(
              diffText,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
