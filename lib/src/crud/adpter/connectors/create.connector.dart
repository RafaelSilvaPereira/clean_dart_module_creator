    


import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';

import '../../crud.exports.dart';

class CreateConnector implements ICreateProtocol {
  final ICreateDriver createDriver;

  const CreateConnector({@required this.createDriver});
}
