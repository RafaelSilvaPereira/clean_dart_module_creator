    


import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';

import '../../crud.exports.dart';

class DeleteUsecase implements IDeleteInterface {
  final IDeleteProtocol deleteProtocol;

  const DeleteUsecase({@required this.deleteProtocol});
}
