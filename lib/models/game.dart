import 'dart:convert';
import 'dart:typed_data';

class Game {
  final String id;
  final String titulo;
  final String plataforma;
  final List<double> avaliacoes;
  String? imagemBase64;

  Game({
    required this.id,
    required this.titulo,
    required this.plataforma,
    List<double>? avaliacoes,
    Uint8List? imagemBytes,
    String? imagemBase64,
  })  : avaliacoes = avaliacoes ?? const [],
        imagemBase64 = imagemBase64 ??
            (imagemBytes == null ? null : base64Encode(imagemBytes));

  double get avaliacao => mediaAvaliacao;

  double get mediaAvaliacao {
    if (avaliacoes.isEmpty) return 0.0;
    final total = avaliacoes.reduce((sum, valor) => sum + valor);
    return total / avaliacoes.length;
  }

  Uint8List? get imagemBytes =>
      imagemBase64 == null ? null : base64Decode(imagemBase64!);

  set imagemBytes(Uint8List? value) {
    imagemBase64 = value == null ? null : base64Encode(value);
  }

  void adicionarAvaliacao(double valor) {
    if (valor < 1 || valor > 5) return;
    avaliacoes.add(valor);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'plataforma': plataforma,
      'avaliacoes': avaliacoes,
      'imagemBase64': imagemBase64,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final avaliacoes = (json['avaliacoes'] as List? ?? const [])
        .map((item) => double.tryParse(item.toString()) ?? 0.0)
        .toList();

    return Game(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: json['titulo']?.toString() ?? '',
      plataforma: json['plataforma']?.toString() ?? '',
      avaliacoes: avaliacoes,
      imagemBase64: json['imagemBase64']?.toString(),
    );
  }
}
