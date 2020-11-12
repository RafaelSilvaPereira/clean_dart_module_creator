    


import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';

import '../../crud.exports.dart';

class DeleteConnector implements IDeleteProtocol {
  final IDeleteDriver deleteDriver;

  const DeleteConnector({@required this.deleteDriver});
}
