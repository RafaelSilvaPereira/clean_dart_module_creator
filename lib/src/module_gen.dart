import 'dart:io';

import 'package:meta/meta.dart';

import 'class_builder.dart';

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

class ModuleFolderGen {
  final int level;
  final String name;
  final ModuleFolderGen parent;
  final String moduleNameInSnackCase;
  ModuleFolderGen({
    @required this.level,
    @required this.name,
    @required this.parent,
    @required this.moduleNameInSnackCase,
  });

  String get separator => Directory.current.path.contains('/') ? '/' : '\\';
  String get exportName => '$name';
  String get path {
    final oldPath = '${(parent?.path ?? Directory.current.path)}';
    final newPath = name != null ? '$separator$name' : '';

    return '$oldPath$newPath';
  }

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

  FileBuilder generateExportFile(List<String> filesNames) {
    final content = filesNames.fold<String>(
        '',
        (previousValue, element) =>
            '''$previousValue\nexport '$element/$element.exports.dart';''');
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

  final messageImportEmpty = '... type here';
  final entityExport = entitiesFolder.generateExportFile([messageImportEmpty]);
  final modelsExport = modelsFolder.generateExportFile([messageImportEmpty]);
  final usecasesExport =
      usecasesFolder.generateExportFile([messageImportEmpty]);
  
  final interfaceExport =
      interfaceFolder.generateExportFile([messageImportEmpty]);
  final protocolExport =
      protocolsFolder.generateExportFile([messageImportEmpty]);
  final connectorExport =
      connectorsFolder.generateExportFile([messageImportEmpty]);
  final datasourcesExport =
      datasourcesFolder.generateExportFile([messageImportEmpty]);
  final driverExport = driversFolder.generateExportFile([messageImportEmpty]);

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

  final classes = [...dataClasses, ...utilClasses];

  for (ClassBuilder classe in classes) {
    createFile(classe.filePath, classe.fileName, classe.toString());
  }

  for (FileBuilder fileBuilder in exportsFiles) {
    createFile(
        fileBuilder.location, fileBuilder.exportName, fileBuilder.content);
  }
}

List<ClassBuilder> createDataClasses(
  String moduleNameInSnackCase,
  String dataclassName, {
  @required ModuleFolderGen modelsFolder,
  @required ModuleFolderGen entitiesFolder,
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
  @required ModuleFolderGen facadeFolder,
  @required ModuleFolderGen interfaceFolder,
  @required ModuleFolderGen protocolsFolder,
  @required ModuleFolderGen driversFolder,
  @required ModuleFolderGen usecasesFolder,
  @required ModuleFolderGen connectorsFolder,
  @required ModuleFolderGen datasourcesFolder,
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
    classTerminology: 'Usecase',
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
  @required bool isInterface,
  @required String classBaseName,
  @required String classTerminology,
  @required ModuleFolderGen moduleFolderGen,
  ClassBuilder classDependecy,
  ClassBuilder classExtension,
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
