import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../domain/entities/wildcard.dart';
import 'mercader_tienda_dialog.dart';

/// Modelo de un nodo en el mapa de mundo estilo Super Mario Bros 3 / Overworld RPG
class NodoMundo {
  final int id;
  final String titulo;
  final String tipo; // 'combate', 'mercader', 'evento', 'jefe'
  final bool desbloqueado;
  final bool completado;
  final Offset posicion; // Coordenadas relativas en la pantalla (0.0 a 1.0)
  final String idQuest;

  const NodoMundo({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.desbloqueado,
    required this.completado,
    required this.posicion,
    required this.idQuest,
  });
}

class MapaMundo2DScreen extends StatefulWidget {
  final String idUsuario;
  final Function(String idQuest) onSeleccionarQuest;

  const MapaMundo2DScreen({
    super.key,
    required this.idUsuario,
    required this.onSeleccionarQuest,
  });

  @override
  State<MapaMundo2DScreen> createState() => _MapaMundo2DScreenState();
}

class _MapaMundo2DScreenState extends State<MapaMundo2DScreen> {
  int _scoreUsuario = 500;
  final Map<TipoWildcard, int> _inventarioUsuario = {
    TipoWildcard.pista: 1,
    TipoWildcard.golpeDoble: 1,
    TipoWildcard.roboDeVida: 1,
    TipoWildcard.cincuentaCincuenta: 1,
  };
  // Configuración del Mundo 1: "Valle de los Algoritmos" (Estilo SMB3)
  final List<NodoMundo> _nodos = const [
    NodoMundo(
      id: 1,
      titulo: '1-1: Variables y Tipos',
      tipo: 'combate',
      desbloqueado: true,
      completado: true,
      posicion: Offset(0.18, 0.72),
      idQuest: '00000000-0000-0000-0000-000000000001',
    ),
    NodoMundo(
      id: 2,
      titulo: '1-2: Condicionales If/Else',
      tipo: 'combate',
      desbloqueado: true,
      completado: false,
      posicion: Offset(0.42, 0.58),
      idQuest: '00000000-0000-0000-0000-000000000001',
    ),
    NodoMundo(
      id: 3,
      titulo: '1-M: Tienda del Mercader',
      tipo: 'mercader',
      desbloqueado: true,
      completado: false,
      posicion: Offset(0.42, 0.32),
      idQuest: '',
    ),
    NodoMundo(
      id: 4,
      titulo: '1-3: Bucles y Funciones',
      tipo: 'combate',
      desbloqueado: false,
      completado: false,
      posicion: Offset(0.68, 0.48),
      idQuest: '00000000-0000-0000-0000-000000000001',
    ),
    NodoMundo(
      id: 5,
      titulo: '1-B: Fortaleza del Boss Final',
      tipo: 'jefe',
      desbloqueado: false,
      completado: false,
      posicion: Offset(0.85, 0.22),
      idQuest: '00000000-0000-0000-0000-000000000001',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C101D),
      appBar: AppBar(
        title: const Text('Mundo 1: Valle de Algoritmos'),
        backgroundColor: const Color(0xFF131728),
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.stars, color: AppTheme.doradoCritico, size: 20),
                const SizedBox(width: 4),
                Text(
                  '1/5 Nodos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.doradoCritico,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;
          final alto = constraints.maxHeight;

          return Stack(
            children: [
              // 1. Capa de dibujo de caminos retro
              CustomPaint(
                size: Size(ancho, alto),
                painter: _CaminoMundoPainter(nodos: _nodos),
              ),

              // 2. Render de cada nodo interactivo
              ..._nodos.map((nodo) {
                final posX = nodo.posicion.dx * ancho - 28;
                final posY = nodo.posicion.dy * alto - 28;

                return Positioned(
                  left: posX,
                  top: posY,
                  child: _NodoWidget(
                    nodo: nodo,
                    onTap: () {
                      if (!nodo.desbloqueado) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Nodo bloqueado! Supera el desafío anterior.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      if (nodo.tipo == 'mercader') {
                        MercaderTiendaDialog.mostrar(
                          context,
                          scoreDisponible: _scoreUsuario,
                          inventarioActual: _inventarioUsuario,





                          onComprar: (tipo, costo) {
                            setState(() {
                              _scoreUsuario -= costo;
                              _inventarioUsuario[tipo] =
                                  (_inventarioUsuario[tipo] ?? 0) + 1;
                            });
                          },

                        );
                        return;
                      }

                      widget.onSeleccionarQuest(nodo.idQuest);
                    },
                  ),
                );
              }),

              // 3. Instrucción inferior estilo retro
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.doradoCritico, width: 2),
                  ),
                  child: const Text(
                    '★ Toca un nodo desbloqueado para iniciar el combate de ingeniería',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _NodoWidget extends StatelessWidget {
  final NodoMundo nodo;
  final VoidCallback onTap;

  const _NodoWidget({required this.nodo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (!nodo.desbloqueado) {
      icon = Icons.lock;
      color = Colors.grey;
    } else if (nodo.completado) {
      icon = Icons.star;
      color = AppTheme.doradoCritico;
    } else {
      switch (nodo.tipo) {
        case 'jefe':
          icon = Icons.castle;
          color = AppTheme.rojoDanio;
          break;
        case 'mercader':
          icon = Icons.storefront;
          color = Colors.purpleAccent;
          break;
        default:
          icon = Icons.shield;
          color = AppTheme.verdeVida;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              nodo.titulo,
              style: TextStyle(
                color: nodo.desbloqueado ? Colors.white : Colors.grey,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _CaminoMundoPainter extends CustomPainter {
  final List<NodoMundo> nodos;

  const _CaminoMundoPainter({required this.nodos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3A506B)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = AppTheme.doradoCritico.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Conectar nodos 1 -> 2 -> 3 y 2 -> 4 -> 5
    if (nodos.length >= 5) {
      final p1 = Offset(nodos[0].posicion.dx * size.width, nodos[0].posicion.dy * size.height);
      final p2 = Offset(nodos[1].posicion.dx * size.width, nodos[1].posicion.dy * size.height);
      final p3 = Offset(nodos[2].posicion.dx * size.width, nodos[2].posicion.dy * size.height);
      final p4 = Offset(nodos[3].posicion.dx * size.width, nodos[3].posicion.dy * size.height);
      final p5 = Offset(nodos[4].posicion.dx * size.width, nodos[4].posicion.dy * size.height);

      canvas.drawLine(p1, p2, paint);
      canvas.drawLine(p2, p3, dashPaint);
      canvas.drawLine(p2, p4, paint);
      canvas.drawLine(p4, p5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
