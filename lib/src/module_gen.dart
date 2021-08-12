import 'dart:io';

import 'package:meta/meta.dart';

import 'class_builder.dart';

///  generate a util methods to get snakeCase and PascalCase from a String
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

/// this class represents a folder into a module
class ModuleFolderGen {
  /// [level] represents how much nested a folder it is
  final int level;

  /// [name] is the name of the folder
  final String name;

  /// [parent] is a folder where this nested
  final ModuleFolderGen? parent;

  /// [moduleNameInSnackCase] is a global name of module
  final String moduleNameInSnackCase;
  ModuleFolderGen({
    required this.level,
    required this.name,
    required this.parent,
    required this.moduleNameInSnackCase,
  });

  /// [separator] returns a '/' or '\\' depending of the current SO file system
  String get separator => Directory.current.path.contains('/') ? '/' : '/';

  /// [exportName] return a name to export file of moduleFolder
  String get exportName => '$name/$name.exports.dart';

  /// [path] returun the current path of module folder
  String get path {
    final oldPath = '${(parent?.path ?? Directory.current.path)}';
    final newPath = name != null ? '$separator$name' : '';

    return '$oldPath$newPath';
  }

  /// [imports] generates a import content to files into this folder
  String get imports {
    String numberOfBars = '';
    for (var i = 0; i < this.level; i++) {
      numberOfBars += '../';
    }
    return '$numberOfBars$moduleNameInSnackCase.exports.dart';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ModuleFolderGen &&
        o.level == level &&
        o.name == name &&
        o.parent == parent;
  }

  @override
  int get hashCode => level.hashCode ^ name.hashCode ^ parent.hashCode;

  @override
  String toString() {
    return 'ModuleFolderGen(level: $level, name: $name, parent: $parent, moduleNameInSnackCase: $moduleNameInSnackCase, path: $path)';
  }

  /// [generateExportFile] make a export file to this folder
  FileBuilder generateExportFile(List<String> filesNames) {
    final content = filesNames.fold<String>('',
        (previousValue, element) => '''$previousValue\nexport '$element';''');
    return FileBuilder(
      '$name',
      path,
      content,
    );
  }
}

generateCode(
  String moduleName,
  List<String> usecasesNames,
  List<String> entitiesNames,
  Function createFolder,
  Function createFile,
) {
  final moduleNameInSnackCase = moduleName.toSnakeCase;
  final moduleFolder = ModuleFolderGen(
    level: 0,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: moduleNameInSnackCase,
    parent: null,
  );

  final facadeFolder = ModuleFolderGen(
    level: 1,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'facade',
    parent: moduleFolder,
  );

  final mainFolder = ModuleFolderGen(
    level: 1,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'main',
    parent: moduleFolder,
  );

  final domainFolder = ModuleFolderGen(
    level: 2,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'domain',
    parent: mainFolder,
  );

  final entitiesFolder = ModuleFolderGen(
    level: 3,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'entities',
    parent: domainFolder,
  );

  final modelsFolder = ModuleFolderGen(
    level: 3,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'models',
    parent: domainFolder,
  );

  final interfaceFolder = ModuleFolderGen(
    level: 2,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'interfaces',
    parent: mainFolder,
  );

  final usecasesFolder = ModuleFolderGen(
    level: 2,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'usecases',
    parent: mainFolder,
  );

  final protocolsFolder = ModuleFolderGen(
    level: 2,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'protocols',
    parent: mainFolder,
  );

  final adpterFolder = ModuleFolderGen(
    level: 1,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'adpter',
    parent: moduleFolder,
  );

  final connectorsFolder = ModuleFolderGen(
    level: 2,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'connectors',
    parent: adpterFolder,
  );

  final driversFolder = ModuleFolderGen(
      level: 2,
      moduleNameInSnackCase: moduleNameInSnackCase,
      name: 'drivers',
      parent: adpterFolder);

  final infraFolder = ModuleFolderGen(
    level: 1,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'infra',
    parent: moduleFolder,
  );

  final datasourcesFolder = ModuleFolderGen(
    level: 2,
    moduleNameInSnackCase: moduleNameInSnackCase,
    name: 'datasources',
    parent: infraFolder,
  );

  final List<ModuleFolderGen> folders = [
    moduleFolder,
    facadeFolder,
    mainFolder,
    domainFolder,
    entitiesFolder,
    modelsFolder,
    interfaceFolder,
    usecasesFolder,
    protocolsFolder,
    adpterFolder,
    connectorsFolder,
    driversFolder,
    infraFolder,
    datasourcesFolder,
  ];

  /// Write Folders
  folders.forEach((folder) {
    createFolder(folder.path);
  });

  final dataClasses = [];
  for (var dataclassName in entitiesNames) {
    dataClasses.addAll(
      createDataClasses(
        moduleName,
        dataclassName,
        entitiesFolder: entitiesFolder,
        modelsFolder: modelsFolder,
      ),
    );
  }

  final utilClasses = [];

  /// Write Files
  for (var utilClassName in usecasesNames) {
    utilClasses.addAll(createUtilsClasses(
      moduleName,
      utilClassName,
      connectorsFolder: connectorsFolder,
      datasourcesFolder: datasourcesFolder,
      driversFolder: driversFolder,
      facadeFolder: facadeFolder,
      interfaceFolder: interfaceFolder,
      protocolsFolder: protocolsFolder,
      usecasesFolder: usecasesFolder,
    ));
  }

  final classes = {'dataClasses': dataClasses, 'utilClasses': utilClasses};

  final entitiesFileNames = <String>[];
  final modelsFileNames = <String>[];
  final protocolsFileNames = <String>[];
  final driversFileNames = <String>[];
  final usecasesFileNames = <String>[];
  final connectorsFileNames = <String>[];
  final datasourcesFileNames = <String>[];
  final interfacesFileNames = <String>[];

  for (ClassBuilder classe in classes['dataClasses'] as Iterable<ClassBuilder>) {
    if (classe.fileName.contains('entity'))
      entitiesFileNames.add(classe.fileName);
    else if (classe.fileName.contains('models'))
      modelsFileNames.add(classe.fileName);
    createFile(classe.filePath, classe.fileName, classe.toString());
  }

  for (ClassBuilder classe in classes['utilClasses'] as Iterable<ClassBuilder>) {
    if (classe.fileName.contains('protocol'))
      protocolsFileNames.add(classe.fileName);
    else if (classe.fileName.contains('usecase'))
      usecasesFileNames.add(classe.fileName);
    else if (classe.fileName.contains('driver'))
      driversFileNames.add(classe.fileName);
    else if (classe.fileName.contains('connector'))
      connectorsFileNames.add(classe.fileName);
    else if (classe.fileName.contains('datasource'))
      datasourcesFileNames.add(classe.fileName);
    else if (classe.fileName.contains('interface'))
      interfacesFileNames.add(classe.fileName);

    createFile(classe.filePath, classe.fileName, classe.toString());
  }

  final entityExport = entitiesFolder.generateExportFile(entitiesFileNames);
  final modelsExport = modelsFolder.generateExportFile(modelsFileNames);
  final usecasesExport = usecasesFolder.generateExportFile(usecasesFileNames);

  final interfaceExport =
      interfaceFolder.generateExportFile(interfacesFileNames);
  final protocolExport = protocolsFolder.generateExportFile(protocolsFileNames);
  final connectorExport =
      connectorsFolder.generateExportFile(connectorsFileNames);
  final datasourcesExport =
      datasourcesFolder.generateExportFile(datasourcesFileNames);
  final driverExport = driversFolder.generateExportFile(driversFileNames);

  final moduleExport = moduleFolder.generateExportFile([
    mainFolder.exportName,
    adpterFolder.exportName,
    infraFolder.exportName,
  ]);
  final mainExport = mainFolder.generateExportFile([
    domainFolder.exportName,
    usecasesFolder.exportName,
    interfaceFolder.exportName,
    protocolsFolder.exportName,
  ]);
  final domainExport = domainFolder.generateExportFile([
    modelsFolder.exportName,
    entitiesFolder.exportName,
  ]);

  final adpterExport = adpterFolder.generateExportFile([
    connectorsFolder.exportName,
    driversFolder.exportName,
  ]);

  final infraExport = infraFolder.generateExportFile([
    datasourcesFolder.exportName,
  ]);

  final List<FileBuilder> exportsFiles = [
    entityExport,
    modelsExport,
    usecasesExport,
    interfaceExport,
    protocolExport,
    connectorExport,
    datasourcesExport,
    driverExport,
    moduleExport,
    mainExport,
    domainExport,
    adpterExport,
    infraExport,
  ];

  for (FileBuilder fileBuilder in exportsFiles) {
    createFile(
        fileBuilder.location, fileBuilder.exportName, fileBuilder.content);
  }
}

/// [createDataClasses]
List<ClassBuilder> createDataClasses(
  String moduleNameInSnackCase,
  String dataclassName, {
  required ModuleFolderGen modelsFolder,
  required ModuleFolderGen entitiesFolder,
}) {
  final entity = createClasses(
    classBaseName: dataclassName,
    classTerminology: 'Entity',
    isInterface: false,
    moduleFolderGen: entitiesFolder,
  );

  final model = createClasses(
    classBaseName: dataclassName,
    classTerminology: 'Model',
    isInterface: false,
    moduleFolderGen: modelsFolder,
    classDependecy: entity,
  );

  return [entity, model];
}

List<ClassBuilder> createUtilsClasses(
  String moduleNameInSnackCase,
  String usecaseClasseBaseName, {
  required ModuleFolderGen facadeFolder,
  required ModuleFolderGen interfaceFolder,
  required ModuleFolderGen protocolsFolder,
  required ModuleFolderGen driversFolder,
  required ModuleFolderGen usecasesFolder,
  required ModuleFolderGen connectorsFolder,
  required ModuleFolderGen datasourcesFolder,
}) {
  final facadeFile = createClasses(
    classBaseName: moduleNameInSnackCase,
    classTerminology: 'Facade',
    isInterface: false,
    moduleFolderGen: facadeFolder,
  );

  /// declare interfaces
  final usecaseInterfaces = createClasses(
    classBaseName: usecaseClasseBaseName,
    classTerminology: 'Interface',
    isInterface: true,
    moduleFolderGen: interfaceFolder,
  );

  final protocolInterface = createClasses(
    classBaseName: usecaseClasseBaseName,
    classTerminology: 'Protocol',
    isInterface: true,
    moduleFolderGen: protocolsFolder,
  );

  final driverInterface = createClasses(
    classBaseName: usecaseClasseBaseName,
    classTerminology: 'Driver',
    isInterface: true,
    moduleFolderGen: driversFolder,
  );

  /// [END]

  /// declare implementation

  final usecaseImpl = createClasses(
    classBaseName: usecaseClasseBaseName,
    classTerminology: 'Usecase',
    isInterface: false,
    moduleFolderGen: usecasesFolder,
    classExtension: usecaseInterfaces,
    classDependecy: protocolInterface,
  );

  final connectorImpl = createClasses(
    classBaseName: usecaseClasseBaseName,
    classTerminology: 'Connector',
    isInterface: false,
    moduleFolderGen: connectorsFolder,
    classExtension: protocolInterface,
    classDependecy: driverInterface,
  );

  final datasourcesImpl = createClasses(
    classBaseName: usecaseClasseBaseName,
    classTerminology: 'Datasource',
    isInterface: false,
    moduleFolderGen: datasourcesFolder,
    classExtension: driverInterface,
  );

  return [
    facadeFile,
    usecaseInterfaces,
    protocolInterface,
    driverInterface,
    usecaseImpl,
    connectorImpl,
    datasourcesImpl,
  ];
}

ClassBuilder createClasses({
  required bool isInterface,
  required String classBaseName,
  required String classTerminology,
  required ModuleFolderGen moduleFolderGen,
  ClassBuilder? classDependecy,
  ClassBuilder? classExtension,
}) {
  final classNameSnackCase = classBaseName.toSnakeCase; // classBaseName
  final classNamePascalCase = classBaseName.toPascalCase; // classBaseName
  final classTermonolgySnackCase =
      classTerminology.toSnakeCase; // classTerminologyclassTermonolgy
  final classTermonolgyPascalCase =
      classTerminology.toPascalCase; // classTermonolgy

  final classBuildered = ClassBuilder(
    imports: moduleFolderGen.imports,
    className: '$classNamePascalCase$classTermonolgyPascalCase',
    isInterface: isInterface,
    fileName: '$classNameSnackCase.$classTermonolgySnackCase',
    location: moduleFolderGen.path,
    dependency: classDependecy,
    superClass: classExtension,
  );
  return classBuildered;
}
