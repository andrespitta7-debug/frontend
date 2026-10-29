import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../combate/combate_screen.dart';
import '../generar/generar_quest_screen.dart';
import 'progreso_controller.dart';

class ProgresoScreen extends StatefulWidget {
  final String idUsuario;
  const ProgresoScreen({super.key, required this.idUsuario});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgresoController>().cargar(widget.idUsuario);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso')),
      body: Consumer<ProgresoController>(
        builder: (context, c, _) {
          if (c.cargando || c.progreso == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = c.progreso!;
          final partidasJugadas = p.partidasJugadas;
          final tasaVictoria = partidasJugadas == 0
              ? 0
              : ((p.victorias / partidasJugadas) * 100).round();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatCard(titulo: 'Nivel', valor: '${p.nivel}'),
                _StatCard(titulo: 'XP total', valor: '${p.xpTotal}'),
                _StatCard(
                  titulo: 'Quests completadas',
                  valor: '${p.questsCompletadas}',
                ),
                _StatCard(
                  titulo: 'Partidas jugadas',
                  valor: '$partidasJugadas',
                ),
                _StatCard(titulo: 'Victorias', valor: '${p.victorias}'),
                _StatCard(titulo: 'Derrotas', valor: '${p.derrotas}'),
                _StatCard(
                  titulo: 'Tasa de victoria',
                  valor: partidasJugadas == 0
                      ? 'Sin partidas aún'
                      : '$tasaVictoria%',
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Nueva quest con IA'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GenerarQuestScreen(idUsuario: widget.idUsuario),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Jugar otra quest'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CombateScreen(
                          idQuest: 'quest-001',
                          idUsuario: widget.idUsuario,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  const _StatCard({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(titulo),
        trailing: Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
