class Insignia {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final Requisito requisito;
  final int puntosOtorgados;
  final bool desbloqueada;

  const Insignia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.requisito,
    required this.puntosOtorgados,
    this.desbloqueada = false,
  });

  Insignia copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? icono,
    Requisito? requisito,
    int? puntosOtorgados,
    bool? desbloqueada,
  }) {
    return Insignia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      requisito: requisito ?? this.requisito,
      puntosOtorgados: puntosOtorgados ?? this.puntosOtorgados,
      desbloqueada: desbloqueada ?? this.desbloqueada,
    );
  }
}

class Requisito {
  final String tipo;
  final int valor;

  const Requisito({
    required this.tipo,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'valor': valor,
    };
  }

  factory Requisito.fromMap(Map<String, dynamic> map) {
    return Requisito(
      tipo: map['tipo'] ?? '',
      valor: map['valor'] ?? 0,
    );
  }
}