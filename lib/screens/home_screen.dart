import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import 'top5_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _storageKey = 'games_salvos';

  final List<Game> _games = [];
  final ImagePicker _picker = ImagePicker();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _carregarGames();
  }

  Future<void> _carregarGames() async {
    _prefs = await SharedPreferences.getInstance();
    final salvos = _prefs.getStringList(_storageKey) ?? [];

    setState(() {
      _games.clear();
      _games.addAll(
        salvos.map((json) => Game.fromJson(jsonDecode(json))).toList(),
      );
    });
  }

  Future<void> _salvarGames() async {
    final lista = _games.map((game) => jsonEncode(game.toJson())).toList();
    await _prefs.setStringList(_storageKey, lista);
  }

  void _adicionarGame(String titulo, String plataforma, double avaliacao,
      [Uint8List? imagemBytes]) {
    final novoGame = Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      plataforma: plataforma,
      avaliacoes: [avaliacao],
      imagemBase64: imagemBytes == null ? null : base64Encode(imagemBytes),
    );

    setState(() {
      _games.add(novoGame);
    });
    _salvarGames();
  }

  Future<void> _selecionarImagem(BuildContext context,
      void Function(Uint8List) onImagemSelecionada) async {
    final imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagem == null) return;

    final bytes = await imagem.readAsBytes();
    onImagemSelecionada(bytes);
  }

  void _abrirAvaliacao(Game game) {
    double novaNota = game.mediaAvaliacao == 0 ? 5.0 : game.mediaAvaliacao;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Avaliar ${game.titulo}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Sua nota: ${novaNota.toStringAsFixed(1)} ★'),
                  Expanded(
                    child: Slider(
                      value: novaNota,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      onChanged: (valor) {
                        setModalState(() => novaNota = valor);
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  game.adicionarAvaliacao(novaNota);
                  _salvarGames();
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: const Text('Salvar avaliação'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirFormularioCadastro() {
    final tituloController = TextEditingController();
    final plataformaController = TextEditingController();
    double nota = 5.0;
    Uint8List? imagemSelecionada;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Novo Game',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (imagemSelecionada != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      imagemSelecionada!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_outlined,
                        size: 54, color: Colors.grey),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _selecionarImagem(context, (bytes) {
                    setModalState(() {
                      imagemSelecionada = bytes;
                    });
                  }),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Adicionar foto do jogo'),
                ),
                TextField(
                  controller: tituloController,
                  decoration:
                      const InputDecoration(labelText: 'Título do Game'),
                ),
                TextField(
                  controller: plataformaController,
                  decoration: const InputDecoration(
                      labelText: 'Plataforma (ex: PS5, PC, Switch)'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Avaliação inicial: ${nota.toStringAsFixed(1)} ★'),
                    Expanded(
                      child: Slider(
                        value: nota,
                        min: 1.0,
                        max: 5.0,
                        divisions: 8,
                        onChanged: (val) {
                          setModalState(() => nota = val);
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (tituloController.text.isNotEmpty) {
                      _adicionarGame(tituloController.text,
                          plataformaController.text, nota, imagemSelecionada);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Salvar Game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Ver Top 5',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Top5Screen(games: _games),
                ),
              );
            },
          ),
        ],
      ),
      body: _games.isEmpty
          ? const Center(child: Text('Nenhum game cadastrado ainda!'))
          : ListView.builder(
              itemCount: _games.length,
              itemBuilder: (ctx, i) {
                final game = _games[i];
                return ListTile(
                  leading: game.imagemBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            game.imagemBytes!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : CircleAvatar(
                          child: Text('${i + 1}'),
                        ),
                  title: Text(game.titulo),
                  subtitle: Text(
                    '${game.plataforma} • ${game.avaliacoes.length} avaliação(ões)',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(game.mediaAvaliacao.toStringAsFixed(1)),
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        onPressed: () => _abrirAvaliacao(game),
                        tooltip: 'Avaliar',
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}
