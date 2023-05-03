class Sofware {
  int? id;
  String? nombre;
  String? version;
  String? sistemaOperativo;

  Sofware({this.id, this.nombre, this.sistemaOperativo, this.version});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre ': nombre,
      'version': version,
      'sistemaOperativo': sistemaOperativo,
    };
  }

  static Sofware fromMap(Map<String, dynamic> map) {
    return Sofware(
      id: map['id'],
      nombre: map['nombre'],
      version: map['version'],
      sistemaOperativo: map['sistemaOperativo'],
    );
  }

  Sofware copyWith({
    int? id,
  String? nombre,
  String? version,
  String? sistemaOperativo,
  }) {
    return Sofware(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      version: version ?? this.version,
      sistemaOperativo: sistemaOperativo ?? this.sistemaOperativo,
    );
  }
}