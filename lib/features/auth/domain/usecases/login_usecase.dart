import 'package:dartz/dartz.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> execute(String email, String password) {
    return repository.login(email, password);
  }
}
