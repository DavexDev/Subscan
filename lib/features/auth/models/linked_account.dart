class LinkedAccount {
  final String id;
  final String email;
  final String? displayName;
  final String userId;
  final DateTime createdAt;
  final String? accessToken; // token de acceso Gmail guardado al vincular

  const LinkedAccount({
    required this.id,
    required this.email,
    this.displayName,
    required this.userId,
    required this.createdAt,
    this.accessToken,
  });

  String get label => displayName ?? email;

  LinkedAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    String? userId,
    DateTime? createdAt,
    String? accessToken,
  }) {
    return LinkedAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedAccount &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
