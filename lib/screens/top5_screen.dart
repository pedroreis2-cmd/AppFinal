import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../models/game.dart';

class Top5Screen extends StatefulWidget {
  final List<Game> games;

  const Top5Screen({super.key, required this.games});

  @override
  State<Top5Screen> createState() => _Top5ScreenState();
}

class _Top5ScreenState extends State<Top5Screen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _compartilharRanking() async {
    final imageBytes = await _screenshotController.capture();

    if (imageBytes != null) {
      final directory = await getTemporaryDirectory();
      final imagePath =
          await File('${directory.path}/top5_ranking.png').create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Confira meu Top 5 Games favoritos!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final top5 = List<Game>.from(widget.games)
      ..sort((a, b) => b.mediaAvaliacao.compareTo(a.mediaAvaliacao));
    final ranking = top5.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top 5 Ranking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: ranking.isNotEmpty ? _compartilharRanking : null,
          ),
        ],
      ),
      body: ranking.isEmpty
          ? const Center(child: Text('Cadastre games para gerar o ranking!'))
          : Column(
              children: [
                Expanded(
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🏆 MEU TOP 5 GAMES 🏆',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(ranking.length, (index) {
                            final game = ranking[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              child: ListTile(
                                leading: game.imagemBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          game.imagemBytes!,
                                          width: 52,
                                          height: 52,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : CircleAvatar(
                                        child: Text('#${index + 1}'),
                                      ),
                                title: Text(game.titulo),
                                subtitle: Text(
                                  '${game.plataforma} • ${game.avaliacoes.length} votos',
                                ),
                                trailing: Text(
                                  '★ ${game.mediaAvaliacao.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _compartilharRanking,
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar Imagem do Ranking'),
                  ),
                ),
              ],
            ),
    );
  }
}
