import 'dart:typed_data';

import 'package:app_final/models/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deve calcular a média das avaliações e serializar a imagem', () {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    final game = Game(
      id: '1',
      titulo: 'Zelda',
      plataforma: 'Switch',
      avaliacoes: [5.0, 4.0, 4.5],
      imagemBytes: bytes,
    );

    expect(game.mediaAvaliacao, closeTo(4.5, 0.01));
    expect(game.toJson()['imagemBase64']?.isNotEmpty, isTrue);

    final copy = Game.fromJson(game.toJson());
    expect(copy.titulo, 'Zelda');
    expect(copy.mediaAvaliacao, closeTo(4.5, 0.01));
    expect(copy.imagemBytes, isNotNull);
  });
}
