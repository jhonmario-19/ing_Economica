class UserModel {
  String uid;
  String nombres;
  String apellidos;
  String email;
  String cedula;
  String telefono;
  double saldo;

  UserModel({
    required this.uid,
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.cedula,
    required this.telefono,
    this.saldo = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'cedula': cedula,
      'telefono': telefono,
      'saldo': saldo,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      email: map['email'],
      cedula: map['cedula'],
      telefono: map['telefono'],
      saldo: map['saldo'] ?? 0.0,
    );
  }
}
