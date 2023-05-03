import 'package:flutter/material.dart';
import 'package:parcial2/model/sofware.dart';
import 'package:parcial2/db/db.dart';

class ListSofware extends StatefulWidget {
  const ListSofware({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListSofwareState createState() => _ListSofwareState();
}

class _ListSofwareState extends State<ListSofware> {
  List<Sofware> _softwares = [];
  final _formKey = GlobalKey<FormState>();
  final _formSearch = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchsoftwares();
  }

  Future<void> _fetchsoftwares() async {
    List<Map<String, dynamic>> rows =
        await DatabaseProvider.instance.queryAllRows();
    List<Sofware> softwares = rows.map((row) => Sofware.fromMap(row)).toList();
    setState(() {
      _softwares = softwares;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Softwares'),
        actions: [
          IconButton(
              onPressed: () {
                _showSearchDialog(context);
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: ListView.builder(
        itemCount: _softwares.length,
        itemBuilder: (context, index) {
          final software = _softwares[index];
          return ListTile(
              title: Text('ID: ${software.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${software.nombre}'),
                  Text('Version: ${software.version}'),
                  Text('Sistema Operativo: ${software.sistemaOperativo}'),
                ],
              ),
              onTap: () => _showCountryDialog(software),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () => _showAlertDialog(software.id!),
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showCountryDialog(null),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Título del diálogo'),
          content: Form(
            key: _formSearch,
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'ID de software',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduce el id del software';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
                onPressed: () async {
                  if (_formSearch.currentState!.validate()) {
                    List<Map<String, dynamic>> rows = await DatabaseProvider
                        .instance
                        .queryRowById(int.parse(searchController.text));
                    List<Sofware> software =
                        rows.map((row) => Sofware.fromMap(row)).toList();
                    if (software.isEmpty) {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      _showErrorDialog(context);
                    } else {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      _showCountryDialog(software[0]);
                    }
                    //_showCountryDialog(software[0]);
                  }
                },
                child: const Text('Buscar'))
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('El software que busca no se encuentra registrado'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSearchDialog(context);
            },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
}

  Future _showAlertDialog(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content:
              const Text('¿Está seguro de que desea eliminar este Software?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseProvider.instance.delete(id);
                _fetchsoftwares();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCountryDialog(Sofware? software) async {
    final isEditing = software != null;
    final nombreController =
        TextEditingController(text: isEditing ? software.nombre : '');
    final versionController =
        TextEditingController(text: isEditing ? software.version : '');
    final sitemaOperativoController =
        TextEditingController(text: isEditing ? software.sistemaOperativo : '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Software' : 'Agregar Software'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: versionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Version',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce la version';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: sitemaOperativoController,
                decoration: const InputDecoration(
                  labelText: 'Sistema operativo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el sistema operativo';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isEditing) {
                if (_formKey.currentState!.validate()) {
                  final updatedSoftware = software.copyWith(
                    nombre: nombreController.text,
                    version: versionController.text,
                    sistemaOperativo: sitemaOperativoController.text,
                  );
                  await DatabaseProvider.instance.updatePais(updatedSoftware);
                }
              } else {
                if (_formKey.currentState!.validate()) {
                  final newSoftware = Sofware(
                    nombre: nombreController.text,
                    version: versionController.text,
                    sistemaOperativo: sitemaOperativoController.text,
                  );
                  await DatabaseProvider.instance.insertPais(newSoftware);
                }
              }
              if (_formKey.currentState!.validate()) {
                _fetchsoftwares();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Guardar cambios' : 'Agregar software'),
          ),
        ],
      ),
    );
  }
}
