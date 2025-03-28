
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/item_ajuste.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: CodeNumberEntryScreen(),
      ),
    );
  }
}

class CodeNumberEntryScreen extends StatefulWidget {
  const CodeNumberEntryScreen({super.key});

  @override
  _CodeNumberEntryScreenState createState() => _CodeNumberEntryScreenState();
}

class _CodeNumberEntryScreenState extends State<CodeNumberEntryScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final List<ItemAjuste> _entries = [];
  final FocusNode _codeFocusNode = FocusNode();

  void _addNumber(String number) {
    setState(() {
      _numberController.text += number;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusCodeField(); // Poner foco inicial en el campo de código
  }

  void _focusCodeField() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _codeFocusNode.requestFocus();
    });
  }

  void _removeLastCharacter() {
    if (_numberController.text.isNotEmpty) {
      setState(() {
        _numberController.text = _numberController.text
            .substring(0, _numberController.text.length - 1);
      });
    }
  }

  void _submit() {
    String code = _codeController.text.trim();
    String numberText = _numberController.text.trim();

    if (code.isNotEmpty && numberText.isNotEmpty) {
      int number = int.tryParse(numberText) ?? 0;

      bool codeExists = false;
      for (var entry in _entries) {
        if (entry.codigoProducto == code) {
          entry.cantidadFisica1 += number;
          codeExists = true;
          break;
        }
      }

      if (!codeExists) {
        _entries.add(ItemAjuste(
          codigoProducto: code,
          cantidadFisica1: number,
          cantidadFisica2: 0,
          codigoEmpresa: '01',
          codigoSucursal: '001',
          codigoBodega: 'B03',
        ));
      }

      setState(() {
        _codeController.clear();
        _numberController.clear();
      });

      _focusCodeField();
    }
  }

  Future<void> _saveToTxt() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay datos para exportar')),
      );
      return;
    }

    String csvData = "";
    for (var entry in _entries) {
      csvData += '$entry\n';
    }

    try {
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);
      await FileSaver.instance.saveFile(name: 'inventario.txt', bytes: bytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  Future<void> _exportToCSV() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay datos para exportar')),
      );
      return;
    }

    String csvData = "";
    for (var entry in _entries) {
      csvData += '$entry\n';
    }

    try {
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      XFile xFile = XFile.fromData(bytes, name: 'inventario.txt');

      await Share.shareXFiles([xFile], text: 'Archivo inventario');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventario Orangepet',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: //color from orange pet
            const Color.fromARGB(254, 241, 54, 6),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              _saveToTxt();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _exportToCSV();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              setState(() {
                _entries.clear();
              });
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _portraitLayout();
          } else {
            return _landscapeLayout();
          }
        },
      ),
    );
  }

  Row _numButtons() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                setState(() {
                  _codeController.text += event.character ?? '';
                });
              }
              return KeyEventResult.handled;
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _codeController,
                readOnly: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Código',
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _numberController,
              readOnly: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'N°',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding _inputs() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Producto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),
          Text(
            "Cantidad",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        List<String> keys = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '⌫',
          '0',
          '✔'
        ];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              if (keys[index] == '⌫') {
                _removeLastCharacter();
              } else if (keys[index] == '✔') {
                _submit();
              } else {
                _addNumber(keys[index]);
              }
            },
            child: Text(
              keys[index],
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntriesList() {
    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  _entries[index].codigoProducto,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _entries[index].cantidadFisica1.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  _portraitLayout() {
    return Column(
      children: [
        _numButtons(),
        _inputs(),
        Expanded(
          child: _buildEntriesList(),
        ),
        _buildNumberPad(),
      ],
    );
  }

  _landscapeLayout() {
    return Row(
      children: [
        Expanded(child: _buildNumberPad()),
        Expanded(
          child: Column(
            children: [
              _numButtons(),
              _inputs(),
              Expanded(
                child: _buildEntriesList(),
              ),
            ],
          ),
        ),
        
      ],
    );
  }
}
