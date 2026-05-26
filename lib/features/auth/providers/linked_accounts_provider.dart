import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:subscan/features/auth/data/linked_accounts_datasource.dart';
import 'package:subscan/features/auth/models/linked_account.dart';

class LinkedAccountsNotifier extends StateNotifier<List<LinkedAccount>> {
  final LinkedAccountsDatasource _datasource;

  LinkedAccountsNotifier(this._datasource) : super([]) {
    load();
  }

  Future<void> load() async {
    try {
      final accounts = await _datasource.getLinkedAccounts();
      state = accounts;
    } catch (e) {
      // ignore: avoid_print
      print('[LinkedAccounts] Error cargando: $e');
    }
  }

  /// Abre el flujo de Google Sign-In, guarda el access token y vincula la cuenta.
  /// Devuelve el email si se vinculó correctamente, lanza excepción si falla.
  Future<String?> addAccount() async {
    const scopes = [
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/userinfo.email',
    ];
    final googleSignIn = GoogleSignIn(scopes: scopes);

    // Forzar selector de cuenta para poder agregar una diferente
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // usuario canceló

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No hay sesión activa');

    // Obtener access token para usarlo en sync sin prompts
    final auth = await googleUser.authentication;
    final accessToken = auth.accessToken;

    final account = LinkedAccount(
      id: '',
      email: googleUser.email,
      displayName: googleUser.displayName,
      userId: uid,
      createdAt: DateTime.now(),
      accessToken: accessToken,
    );

    await _datasource.addLinkedAccount(account);
    await load();
    return googleUser.email;
  }

  Future<void> removeAccount(String id) async {
    await _datasource.removeLinkedAccount(id);
    state = state.where((a) => a.id != id).toList();
  }
}

final linkedAccountsDatasourceProvider = Provider<LinkedAccountsDatasource>((ref) {
  return LinkedAccountsDatasource();
});

final linkedAccountsProvider =
    StateNotifierProvider<LinkedAccountsNotifier, List<LinkedAccount>>((ref) {
  final datasource = ref.watch(linkedAccountsDatasourceProvider);
  return LinkedAccountsNotifier(datasource);
});
