import 'package:meta/meta.dart';

class FileBuilder {
  final String name;
  final String location;
  final String content;

  const FileBuilder._(this.name, this.location, this.content);
  factory FileBuilder(String name, String location, String content) {
    return FileBuilder._('$name.dart', location, content);
  }

  get exportName => name.replaceAll('.dart', '.exports.dart');

  @override
  String toString() =>
      'FileBuilder(name: $name, location: $location, content: $content)';
}

class ClassBuilder {
  final FileBuilder fileBuilder;
  final String className;
  final ClassBuilder dependency;
  final ClassBuilder superClass;
  final bool isInterface;
  final String imports;

  const ClassBuilder._({
    @required this.fileBuilder,
    @required this.className,
    @required this.isInterface,
    this.superClass,
    this.dependency,
    this.imports = '',
  });

  factory ClassBuilder.specific({
    @required String className,
    @required bool isInterface,
    @required String fileName,
    @required String location,
    @required String content,
  }) {
    return ClassBuilder._(
      fileBuilder: FileBuilder(fileName, location, content),
      className: className,
      isInterface: isInterface,
    );
  }
  factory ClassBuilder({
    @required String className,
    @required bool isInterface,
    @required String fileName,
    @required String location,
    ClassBuilder superClass,
    ClassBuilder dependency,
    String imports = '',
  }) {
    final bool validDepency = getValidDependency(dependency);

    final fullClassName = getFullClassName(validDepency, dependency);
    final fullPropertyName = getFullProptertyName(validDepency, dependency);
    var properties;
    properties = getProperties(
        isInterface, validDepency, properties, fullClassName, dependency);
    final String classPrefix = getClassPrefix(isInterface);
    final String _className = getClassFullName(isInterface, className);

    final constructorParams =
        getConstructorParams(dependency, fullPropertyName);
    final constructor =
        getConstructor(isInterface, _className, constructorParams);

    final supClass =
        superClass != null ? 'implements ${superClass?.realClassName}' : '';
    final content = '''\n

import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';

import '${imports.trim()}';

$classPrefix $_className $supClass {
  $properties

  $constructor
}
''';

    return ClassBuilder._(
      isInterface: isInterface,
      className: className,
      dependency: dependency,
      fileBuilder: FileBuilder(fileName, location, content),
    );
  }

  static String getConstructor(
      bool isInterface, String _className, String constructorParams) {
    return !isInterface ? 'const $_className($constructorParams);' : '';
  }

  static String getConstructorParams(
          ClassBuilder dependency, String fullPropertyName) =>
      dependency != null ? '{$fullPropertyName}' : '';

  static String getClassFullName(bool isInterface, String className) =>
      isInterface ? 'I$className' : className;

  static String getClassPrefix(bool isInterface) =>
      isInterface ? 'abstract class' : 'class';

  static String getProperties(bool isInterface, bool validDepency, properties,
      String fullClassName, ClassBuilder dependency) {
    if (!isInterface && validDepency) {
      properties =
          'final I$fullClassName ${dependency.className[0].toLowerCase() + dependency.className.substring(1)};';
    } else {
      properties = '';
    }
    return properties;
  }

  static String getFullProptertyName(
      bool validDepency, ClassBuilder dependency) {
    return validDepency
        ? '@required this.' +
            dependency.className[0].toLowerCase() +
            dependency.className.substring(1)
        : '';
  }

  static String getFullClassName(bool validDepency, ClassBuilder dependency) =>
      validDepency ? dependency.className : '';

  static bool getValidDependency(ClassBuilder dependency) {
    return dependency != null && dependency.className.length > 0;
  }

  String get classPrefix => isInterface ? 'abstract class' : 'class';
  String get realClassName => isInterface ? 'I$className' : className;

  String get filePath => fileBuilder.location;
  String get fileName => fileBuilder.name;
  @override
  toString() {
    return ''' 
    ${fileBuilder.content}''';
  }
}

main() {
  ClassBuilder entity = ClassBuilder(
    isInterface: false,
    className: 'AlunoEntity',
    fileName: 'aluno.entity',
    location: '/home/devrafael/projects/dart/clean_dart_module_creator/entity',
  );

  final usecaseInterface = ClassBuilder(
    fileName: 'create_user.usecase',
    isInterface: true,
    location: '/',
    className: 'CreateUserUsecase',
    imports: '''
    import 'x.dart'cl;
    ''',
  );

  final usecase = ClassBuilder(
    fileName: 'create_user.usecase',
    isInterface: false,
    superClass: usecaseInterface,
    dependency: entity,
    location: '/',
    className: 'CreateUserUsecase',
    imports: '''
    import 'x.dart';
    ''',
  );

  print(usecase.toString());
}
