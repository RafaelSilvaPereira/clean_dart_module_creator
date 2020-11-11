import 'dart:io';
import 'package:args/args.dart';

import 'module_gen.dart';

final MODULE = 'module';
final USER_CASES = 'usercases';
final ENTITIES = 'entities';

extension toOtherCases on String {
  String get toSnakeCase {
    return this.trim().toLowerCase().split(' ').join('_');
  }

  String get toPascalCase {
    return this.trim().split(' ').fold(
        '',
        (previousValue, e) =>
            '$previousValue${e[0].toUpperCase()}${e.substring(1)}');
  }
}

void execMain(List<String> arguments) {
  //print('Hello world: ${create_modules_cli.calculate()}!');
  final parser = ArgParser()
    ..addOption(MODULE, abbr: 'm')
    ..addOption(USER_CASES, abbr: 'u')
    ..addOption(ENTITIES, abbr: 'e');

  var params = parser.parse(arguments);

  if (checkIfParametersDiferentNull(params)) {
    print('Ok!');
    String moduleName = params[MODULE];
    List<String> usercasesNames = getFormatedEntry(params[USER_CASES]);
    List<String> entitiesNames = getFormatedEntry(params[ENTITIES]);
    generateCode(
        moduleName, usercasesNames, entitiesNames, mkdirFolder, writeFile);
  } else {
    print('A escrita feliz ');
  }
}

bool checkIfParametersDiferentNull(ArgResults params) {
  return (params[MODULE] != null &&
      params[ENTITIES] != null &&
      params[USER_CASES] != null);
}

List<String> getFormatedEntry(String entry) {
  List<String> list = entry.split(',');

  bool haveEmptyData = true;
  while (haveEmptyData) {
    haveEmptyData = list.remove('');
  }

  return list;
}

//// Arquivos

FileOperation writeFile(String filePath, String fileName, String content) {
  var path = '$filePath/$fileName';
  var operation = FileOperation(true, 'Sucesso ao criar o arquivo');

  try {
    File(path).writeAsStringSync(content);
  } catch (e) {
    print(e);
    operation.update(false, e.toString());
  }

  return operation;
}

mkdirFolder(String path) {
  Directory.fromUri(Uri(path: path)).createSync(recursive: true);
}

// escreverArquivo(local: String, nomeArquivo: String, conteudo: String )

void run() {
  var operation = writeFile('/tmp', 'teste.txt', 'Oi mundo');
  print(operation.message);
}

class FileOperation {
  String message;
  bool isComplete;

  FileOperation(bool isComplete, String message) {
    update(isComplete, message);
  }

  void update(bool isComplete, String message) {
    this.isComplete = isComplete;
    this.message = message;
  }
}
