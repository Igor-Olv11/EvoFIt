import 'package:flutter/material.dart';

import '../models/perfil.dart';
import '../models/avaliacao.dart';

class HomeScreen extends StatelessWidget {
  final Perfil? perfil;
  final List<Avaliacao> avaliacoes;
  final VoidCallback onNovaAvaliacao;
  final VoidCallback onOpenPerfil;

  const HomeScreen({
    super.key,
    required this.perfil,
    required this.avaliacoes,
    required this.onNovaAvaliacao,
    required this.onOpenPerfil,
  });

  @override
  Widget build(BuildContext context) {
    final latest = avaliacoes.isNotEmpty ? avaliacoes.first : null;
    final pesoAtual = latest?.peso ?? perfil?.peso;
    final pesoMeta = perfil?.pesoMeta;
    final pesoInicial = perfil?.peso;
    final progresso = pesoAtual != null &&
            pesoMeta != null &&
            pesoInicial != null &&
            pesoMeta != pesoInicial
        ? ((pesoAtual - pesoInicial) / (pesoMeta - pesoInicial))
            .clamp(0.0, 1.0)
        : null;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perfil == null || perfil!.nome.trim().isEmpty
                              ? 'Olá 👋'
                              : 'Olá, ${perfil!.nome} 👋',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Acompanhe sua evolução.',
                          style: TextStyle(color: Colors.white.withOpacity(.65)),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onOpenPerfil,
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _GoalCard(
                objetivo: perfil?.objetivo ?? 'Defina seu objetivo',
                pesoAtual: pesoAtual,
                pesoMeta: pesoMeta,
                progresso: progresso,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 58,
                child: FilledButton.icon(
                  onPressed: onNovaAvaliacao,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'NOVA AVALIAÇÃO',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Resumo',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            sliver: SliverToBoxAdapter(
              child: _SummaryGrid(
                latest: latest,
                hasProfile: perfil != null,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverToBoxAdapter(
              child: _LastEvaluationCard(latest: latest),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String objetivo;
  final double? pesoAtual;
  final double? pesoMeta;
  final double? progresso;

  const _GoalCard({
    required this.objetivo,
    required this.pesoAtual,
    required this.pesoMeta,
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: Color(0xFF2196F3)),
                const SizedBox(width: 10),
                Text(
                  'Seu objetivo',
                  style: TextStyle(color: Colors.white.withOpacity(.65)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              objetivo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (pesoAtual != null || pesoMeta != null) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'Peso atual',
                      value: pesoAtual == null
                          ? '--'
                          : '${pesoAtual!.toStringAsFixed(1)} kg',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: 'Peso meta',
                      value: pesoMeta == null
                          ? '--'
                          : '${pesoMeta!.toStringAsFixed(1)} kg',
                    ),
                  ),
                ],
              ),
              if (progresso != null) ...[
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 7,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final Avaliacao? latest;
  final bool hasProfile;

  const _SummaryGrid({required this.latest, required this.hasProfile});

  double? _media(double? direita, double? esquerda) {
    if (direita != null && esquerda != null) {
      return (direita + esquerda) / 2;
    }
    return direita ?? esquerda;
  }

  String _format(double? value, {String unit = 'cm'}) {
    if (value == null) return '--';
    return '${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Peso',
        value: latest == null ? '--' : _format(latest!.peso, unit: 'kg'),
      ),
      _SummaryItem(
        icon: Icons.straighten,
        label: 'Cintura',
        value: _format(latest?.cintura),
      ),
      _SummaryItem(
        icon: Icons.fitness_center,
        label: 'Braço',
        value: _format(
          _media(latest?.bracoDireitoContraido, latest?.bracoEsquerdoContraido),
        ),
      ),
      _SummaryItem(
        icon: Icons.fitness_center,
        label: 'Antebraço',
        value: _format(
          _media(latest?.antebracoDireito, latest?.antebracoEsquerdo),
        ),
      ),
      _SummaryItem(
        icon: Icons.directions_run,
        label: 'Coxa',
        value: _format(_media(latest?.coxaDireita, latest?.coxaEsquerda)),
      ),
      _SummaryItem(
        icon: Icons.directions_walk,
        label: 'Panturrilha',
        value: _format(
          _media(latest?.panturrilhaDireita, latest?.panturrilhaEsquerda),
        ),
      ),
      _SummaryItem(
        icon: Icons.accessibility_new,
        label: 'Ombros',
        value: _format(latest?.ombros),
      ),
      _SummaryItem(
        icon: Icons.accessibility,
        label: 'Peito',
        value: _format(latest?.peito),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 116,
      ),
      itemBuilder: (_, index) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: _Metric(
            icon: items[index].icon,
            label: items[index].label,
            value: items[index].value,
          ),
        ),
      ),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _Metric extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;

  const _Metric({
    this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: 20, color: const Color(0xFF2196F3)),
        if (icon != null) const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(.58)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ],
    );
  }
}

class _LastEvaluationCard extends StatelessWidget {
  final Avaliacao? latest;

  const _LastEvaluationCard({required this.latest});

  @override
  Widget build(BuildContext context) {
    if (latest == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Faça sua primeira avaliação para começar a acompanhar sua evolução.',
                  style: TextStyle(color: Colors.white.withOpacity(.72)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final d = latest!.data;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x222196F3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última avaliação',
                    style: TextStyle(color: Colors.white.withOpacity(.6)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${latest!.peso.toStringAsFixed(1)} kg',
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
