import 'package:dartz/dartz.dart';
import '../entities/auth_entity.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthEntity>> checkAuthStatus();
}
