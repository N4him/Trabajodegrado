import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/insignia.dart';
class InsigniaModel extends Insignia {
  const InsigniaModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    required super.requisito,
    required super.puntosOtorgados,
    super.desbloqueada,
  });

  factory InsigniaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return InsigniaModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      icono: data['icono'] ?? '',
      requisito: Requisito.fromMap(data['requisito'] ?? {}),
      puntosOtorgados: data['puntos_otorgados'] ?? 0,
      desbloqueada: false,
    );
  }

  @override
  InsigniaModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? icono,
    Requisito? requisito,
    int? puntosOtorgados,
    bool? desbloqueada,
  }) {
    return InsigniaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      requisito: requisito ?? this.requisito,
      puntosOtorgados: puntosOtorgados ?? this.puntosOtorgados,
      desbloqueada: desbloqueada ?? this.desbloqueada,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'requisito': requisito.toMap(),
      'puntos_otorgados': puntosOtorgados,
    };
  }
}