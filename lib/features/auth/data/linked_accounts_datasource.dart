import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:subscan/features/auth/models/linked_account.dart';

class LinkedAccountsDatasource {
  final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'linked_accounts';

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No hay sesión activa');
    return uid;
  }

  Future<List<LinkedAccount>> getLinkedAccounts() async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: true);

    return (response as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addLinkedAccount(LinkedAccount account) async {
    await _client.from(_table).upsert({
      'user_id': _uid,
      'email': account.email,
      'display_name': account.displayName,
      'access_token': account.accessToken,
    }, onConflict: 'user_id,email');
  }

  Future<void> removeLinkedAccount(String id) async {
    await _client.from(_table).delete().eq('id', id).eq('user_id', _uid);
  }

  LinkedAccount _fromRow(Map<String, dynamic> row) {
    return LinkedAccount(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String?,
      userId: row['user_id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      accessToken: row['access_token'] as String?,
    );
  }
}
