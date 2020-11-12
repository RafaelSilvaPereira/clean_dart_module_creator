    


import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';

import '../../crud.exports.dart';

class CreateUsecase implements ICreateInterface {
  final ICreateProtocol createProtocol;

  const CreateUsecase({@required this.createProtocol});
}
